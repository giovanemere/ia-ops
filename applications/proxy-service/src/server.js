// =============================================================================
// IA-OPS PROXY SERVICE - SERVIDOR PRINCIPAL COMPLETO
// =============================================================================

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const morgan = require('morgan');
const winston = require('winston');
require('dotenv').config();

// =============================================================================
// CONFIGURACIÓN
// =============================================================================

const app = express();
const PORT = process.env.PROXY_SERVICE_PORT || 8080;
const HOST = process.env.PROXY_SERVICE_HOST || '0.0.0.0';

// Logger configuration
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/proxy-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/proxy-combined.log' })
  ]
});

// =============================================================================
// MIDDLEWARE GLOBAL
// =============================================================================

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "ws:", "wss:", "http:", "https:"]
    }
  }
}));

// Compression
app.use(compression());

// CORS configuration
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://localhost:7007',
    'http://localhost:8080',
    process.env.BACKSTAGE_BASE_URL,
    process.env.BACKSTAGE_FRONTEND_URL
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.PROXY_RATE_LIMIT || 200,
  message: {
    error: 'Too many requests from this IP',
    retryAfter: '15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false
});
app.use(limiter);

// Request logging
app.use(morgan('combined', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// =============================================================================
// HEALTH CHECK
// =============================================================================

app.get('/health', (req, res) => {
  const healthCheck = {
    uptime: process.uptime(),
    message: 'Proxy Service is healthy',
    timestamp: new Date().toISOString(),
    services: {
      backstage_frontend: 'http://backstage-frontend:3000',
      backstage_backend: 'http://backstage-backend:7007',
      openai_service: 'http://openai-service:8000'
    }
  };
  
  logger.info('Health check requested', healthCheck);
  res.status(200).json(healthCheck);
});

// =============================================================================
// PROXY CONFIGURATIONS
// =============================================================================

// Backstage Backend API Proxy
const backstageBackendProxy = createProxyMiddleware({
  target: 'http://backstage-backend:7007',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '' // Remove /api prefix when forwarding
  },
  timeout: (process.env.PROXY_TIMEOUT || 30) * 1000,
  onError: (err, req, res) => {
    logger.error('Backstage Backend Proxy Error:', err);
    res.status(500).json({ error: 'Backstage Backend service unavailable' });
  },
  onProxyReq: (proxyReq, req, res) => {
    logger.debug(`Proxying to Backstage Backend: ${req.method} ${req.url}`);
  }
});

// OpenAI Service Proxy
const openaiServiceProxy = createProxyMiddleware({
  target: 'http://openai-service:8000',
  changeOrigin: true,
  pathRewrite: {
    '^/openai': '' // Remove /openai prefix when forwarding
  },
  timeout: (process.env.PROXY_TIMEOUT || 30) * 1000,
  onError: (err, req, res) => {
    logger.error('OpenAI Service Proxy Error:', err);
    res.status(500).json({ error: 'OpenAI service unavailable' });
  },
  onProxyReq: (proxyReq, req, res) => {
    logger.debug(`Proxying to OpenAI Service: ${req.method} ${req.url}`);
    // Add authorization header if available
    if (process.env.OPENAI_API_KEY) {
      proxyReq.setHeader('Authorization', `Bearer ${process.env.OPENAI_API_KEY}`);
    }
  }
});

// Backstage Frontend Proxy (for static assets and SPA)
const backstageFrontendProxy = createProxyMiddleware({
  target: 'http://backstage-frontend:3000',
  changeOrigin: true,
  ws: true, // Enable WebSocket proxying
  timeout: (process.env.PROXY_TIMEOUT || 30) * 1000,
  onError: (err, req, res) => {
    logger.error('Backstage Frontend Proxy Error:', err);
    res.status(500).json({ error: 'Backstage Frontend service unavailable' });
  },
  onProxyReq: (proxyReq, req, res) => {
    logger.debug(`Proxying to Backstage Frontend: ${req.method} ${req.url}`);
  }
});

// =============================================================================
// ROUTES
// =============================================================================

// API routes (Backstage Backend)
app.use('/api', backstageBackendProxy);

// OpenAI Service routes
app.use('/openai', openaiServiceProxy);

// Default route info
app.get('/info', (req, res) => {
  res.json({
    message: 'IA-Ops Proxy Service',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      info: '/info',
      api: '/api/*',
      openai: '/openai/*',
      frontend: '/* (fallback)'
    },
    services: {
      backstage_frontend: 'http://backstage-frontend:3000',
      backstage_backend: 'http://backstage-backend:7007',
      openai_service: 'http://openai-service:8000'
    }
  });
});

// Static assets and frontend (Backstage Frontend) - MUST BE LAST
app.use('/', backstageFrontendProxy);

// =============================================================================
// ERROR HANDLING
// =============================================================================

// Global error handler
app.use((err, req, res, next) => {
  logger.error('Global error handler:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    timestamp: new Date().toISOString()
  });
});

// =============================================================================
// SERVER STARTUP
// =============================================================================

const server = app.listen(PORT, HOST, () => {
  logger.info(`🚀 IA-Ops Proxy Service started`);
  logger.info(`📡 Server running on http://${HOST}:${PORT}`);
  logger.info(`🏛️ Backstage Frontend: http://backstage-frontend:3000`);
  logger.info(`🔧 Backstage Backend: http://backstage-backend:7007`);
  logger.info(`🤖 OpenAI Service: http://openai-service:8000`);
  logger.info(`📊 Rate Limit: ${process.env.PROXY_RATE_LIMIT || 200} requests/15min`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

module.exports = app;
