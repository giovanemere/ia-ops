// =============================================================================
// IA-OPS PROXY SERVICE - VERSIÓN SIMPLIFICADA
// =============================================================================

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PROXY_SERVICE_PORT || 8080;

// CORS configuration
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Body parsing
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({
    uptime: process.uptime(),
    message: 'Proxy Service is healthy',
    timestamp: new Date().toISOString(),
    services: {
      openai_service: 'http://openai-service:8000'
    }
  });
});

// OpenAI Service Proxy
const openaiProxy = createProxyMiddleware({
  target: 'http://openai-service:8000',
  changeOrigin: true,
  pathRewrite: {
    '^/openai': ''
  },
  onError: (err, req, res) => {
    console.error('OpenAI Proxy Error:', err.message);
    res.status(500).json({ error: 'OpenAI service unavailable' });
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`Proxying to OpenAI: ${req.method} ${req.url}`);
  }
});

// Routes
app.use('/openai', openaiProxy);

// Default route
app.get('/', (req, res) => {
  res.json({
    message: 'IA-Ops Proxy Service',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      openai: '/openai/*'
    }
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 IA-Ops Proxy Service started on http://0.0.0.0:${PORT}`);
  console.log(`🤖 OpenAI Service: http://openai-service:8000`);
});

module.exports = app;
