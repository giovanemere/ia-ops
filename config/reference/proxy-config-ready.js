// =============================================================================
// CONFIGURACIÓN DE PROXY LISTA PARA BACKSTAGE DOCKER
// =============================================================================
// Usar cuando Backstage esté funcionando en Docker Compose

// Backstage Frontend Proxy (Docker)
const backstageFrontendProxy = createProxyMiddleware({
  target: 'http://backstage-frontend:3000',  // Docker service
  changeOrigin: true,
  ws: true,
  timeout: 30000,
  onError: (err, req, res) => {
    logger.error('Backstage Frontend Proxy Error:', err);
    // Fallback to local if Docker service fails
    res.redirect('http://localhost:3000' + req.url);
  }
});

// Backstage Backend Proxy (Docker)
const backstageBackendProxy = createProxyMiddleware({
  target: 'http://backstage-backend:7007',   // Docker service
  changeOrigin: true,
  pathRewrite: { '^/api': '' },
  timeout: 30000,
  onError: (err, req, res) => {
    logger.error('Backstage Backend Proxy Error:', err);
    res.status(500).json({ error: 'Backstage Backend service unavailable' });
  }
});

// Routes
app.use('/api', backstageBackendProxy);
app.use('/openai', openaiServiceProxy);
app.use('/', backstageFrontendProxy);  // Fallback to frontend
