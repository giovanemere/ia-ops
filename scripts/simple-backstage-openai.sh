#!/bin/bash

# =============================================================================
# BACKSTAGE SIMPLE CON PROXY OPENAI
# =============================================================================

set -e

echo "🤖 Configurando Backstage con proxy OpenAI..."

# Cargar variables
source .env

# Detener servicios existentes
echo "⏹️  Deteniendo servicios existentes..."
docker stop ia-ops-backstage 2>/dev/null || true
docker rm ia-ops-backstage 2>/dev/null || true

# Verificar PostgreSQL
if ! docker ps | grep -q ia-ops-postgres; then
    echo "🗄️  Iniciando PostgreSQL..."
    docker run -d \
      --name ia-ops-postgres \
      --network host \
      -e POSTGRES_USER=$POSTGRES_USER \
      -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
      -e POSTGRES_DB=$POSTGRES_DB \
      -p 5432:5432 \
      postgres:15
    
    echo "⏳ Esperando PostgreSQL..."
    sleep 15
fi

# Crear app-config.yaml con proxy OpenAI
echo "📝 Creando configuración con proxy OpenAI..."
cat > app-config.simple.yaml << EOF
app:
  title: IA-Ops Platform
  baseUrl: http://localhost:3000

organization:
  name: IA-Ops

backend:
  auth:
    keys:
      - secret: ${BACKEND_SECRET}
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0
  csp:
    connect-src: ["'self'", 'http:', 'https:', 'https://api.openai.com']
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  database:
    client: pg
    connection:
      host: localhost
      port: 5432
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}

# Proxy para OpenAI - Accesible desde el frontend
proxy:
  '/openai':
    target: 'https://api.openai.com/v1'
    changeOrigin: true
    headers:
      Authorization: 'Bearer ${OPENAI_API_KEY}'
      Content-Type: 'application/json'
    pathRewrite:
      '^/openai': ''

  # Proxy adicional para testing
  '/test-openai':
    target: 'https://api.openai.com/v1/models'
    changeOrigin: true
    headers:
      Authorization: 'Bearer ${OPENAI_API_KEY}'

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

auth:
  environment: development
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location, User, Group, Domain]
  locations:
    - type: file
      target: ./catalog-info.yaml
    - type: file
      target: ./users.yaml
  providers:
    github:
      providerId:
        organization: '${GITHUB_ORG}'
        catalogPath: '/catalog-info.yaml'
        filters:
          branch: 'main'
          repository: '.*'
        schedule:
          frequency: { minutes: 30 }
          timeout: { minutes: 3 }

techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'

search:
  pg:
    highlightOptions:
      useHighlight: true
EOF

# Crear página HTML simple para probar OpenAI
echo "📄 Creando página de prueba OpenAI..."
mkdir -p static
cat > static/openai-test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>OpenAI Test - IA-Ops Platform</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        textarea { width: 100%; height: 100px; margin: 10px 0; }
        button { background: #1976d2; color: white; padding: 10px 20px; border: none; cursor: pointer; }
        .response { background: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 5px; }
        .loading { color: #666; font-style: italic; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 OpenAI Integration Test</h1>
        <p>Test the OpenAI integration in Backstage</p>
        
        <div>
            <label for="prompt">Ask the AI:</label>
            <textarea id="prompt" placeholder="Example: Explain what Backstage is and how it helps developers"></textarea>
            <button onclick="askAI()">Ask AI</button>
        </div>
        
        <div id="response" class="response" style="display: none;"></div>
    </div>

    <script>
        async function askAI() {
            const prompt = document.getElementById('prompt').value;
            const responseDiv = document.getElementById('response');
            
            if (!prompt.trim()) {
                alert('Please enter a question');
                return;
            }
            
            responseDiv.style.display = 'block';
            responseDiv.innerHTML = '<div class="loading">🤔 AI is thinking...</div>';
            
            try {
                const response = await fetch('/api/proxy/openai/chat/completions', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        model: 'gpt-4o-mini',
                        messages: [
                            {
                                role: 'system',
                                content: 'You are a helpful AI assistant integrated with Backstage, a developer portal platform. Help users with development questions and Backstage-related topics.'
                            },
                            {
                                role: 'user',
                                content: prompt
                            }
                        ],
                        max_tokens: 2000,
                        temperature: 0.7
                    }),
                });
                
                const data = await response.json();
                
                if (data.choices && data.choices[0]) {
                    responseDiv.innerHTML = '<h3>🤖 AI Response:</h3><p>' + 
                        data.choices[0].message.content.replace(/\n/g, '<br>') + '</p>';
                } else {
                    responseDiv.innerHTML = '<div class="error">❌ No response from AI</div>';
                }
            } catch (error) {
                responseDiv.innerHTML = '<div class="error">❌ Error: ' + error.message + '</div>';
            }
        }
        
        // Test connection on load
        window.onload = async function() {
            try {
                const response = await fetch('/api/proxy/test-openai');
                console.log('OpenAI connection test:', response.status);
            } catch (error) {
                console.error('OpenAI connection test failed:', error);
            }
        };
    </script>
</body>
</html>
EOF

# Crear Dockerfile simple
echo "🐳 Creando Dockerfile simple..."
cat > Dockerfile.simple-openai << 'EOF'
FROM node:18-bullseye-slim

RUN apt-get update && apt-get install -y \
    python3 g++ make git curl netcat \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar Backstage CLI
RUN npm install -g @backstage/create-app@latest

# Crear app Backstage
RUN npx @backstage/create-app@latest --skip-install backstage-app

WORKDIR /app/backstage-app

# Instalar dependencias
RUN yarn install

# Copiar configuración
COPY app-config.simple.yaml ./app-config.yaml
COPY catalog-info.yaml ./
COPY users.yaml ./
COPY static ./static

# Servir archivos estáticos
RUN mkdir -p packages/backend/static && cp -r static/* packages/backend/static/

EXPOSE 3000 7007

CMD bash -c "
    echo 'Esperando PostgreSQL...' && \
    while ! nc -z localhost 5432; do sleep 1; done && \
    echo 'Iniciando backend...' && \
    yarn workspace backend start &
    sleep 30 && \
    echo 'Iniciando frontend...' && \
    yarn workspace app start
"
EOF

# Construir y ejecutar
echo "🏗️  Construyendo imagen simple..."
docker build -f Dockerfile.simple-openai -t backstage-simple-openai .

echo "🚀 Iniciando Backstage con proxy OpenAI..."
docker run -d \
  --name ia-ops-backstage \
  --network host \
  -e POSTGRES_HOST=localhost \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$POSTGRES_DB \
  -e BACKEND_SECRET=$BACKEND_SECRET \
  -e AUTH_GITHUB_CLIENT_ID=$AUTH_GITHUB_CLIENT_ID \
  -e AUTH_GITHUB_CLIENT_SECRET=$AUTH_GITHUB_CLIENT_SECRET \
  -e GITHUB_TOKEN=$GITHUB_TOKEN \
  -e GITHUB_ORG=$GITHUB_ORG \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  -p 3000:3000 \
  -p 7007:7007 \
  backstage-simple-openai

echo "⏳ Esperando Backstage (2-3 minutos)..."
sleep 90

# Verificar servicios
echo "✅ Verificando servicios..."

if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
    echo "✅ Backend funcionando: http://localhost:7007"
else
    echo "⚠️  Backend iniciando..."
fi

if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    echo "✅ Frontend funcionando: http://localhost:3000"
else
    echo "⚠️  Frontend iniciando..."
fi

# Probar proxy OpenAI
echo "🤖 Probando proxy OpenAI..."
if curl -s -H "Authorization: Bearer $OPENAI_API_KEY" "http://localhost:7007/api/proxy/test-openai" | grep -q "gpt"; then
    echo "✅ Proxy OpenAI funcionando"
else
    echo "⚠️  Proxy OpenAI puede estar configurándose..."
fi

echo ""
echo "🎉 Backstage con OpenAI está listo:"
echo "   🌐 Frontend: http://localhost:3000"
echo "   🔧 Backend: http://localhost:7007"
echo "   🤖 Test OpenAI: http://localhost:3000/static/openai-test.html"
echo ""
echo "🔗 Endpoints OpenAI disponibles:"
echo "   • POST /api/proxy/openai/chat/completions"
echo "   • GET /api/proxy/test-openai"
echo ""
echo "📋 Para usar OpenAI desde el frontend:"
echo "   fetch('/api/proxy/openai/chat/completions', { method: 'POST', ... })"
echo ""
echo "📊 Para ver logs: docker logs -f ia-ops-backstage"
