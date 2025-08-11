#!/bin/bash

# =============================================================================
# SETUP BACKSTAGE CON INTEGRACIÓN OPENAI
# =============================================================================

set -e

echo "🤖 Configurando Backstage con integración OpenAI..."

# Cargar variables
source .env

# Detener servicios existentes
echo "⏹️  Deteniendo servicios existentes..."
docker stop ia-ops-backstage 2>/dev/null || true
docker rm ia-ops-backstage 2>/dev/null || true

# Verificar que PostgreSQL esté corriendo
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

# Crear app-config.yaml con integración OpenAI
echo "📝 Creando configuración con OpenAI..."
cat > app-config.openai.yaml << EOF
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

# Configuración de OpenAI
openai:
  apiKey: ${OPENAI_API_KEY}
  model: ${OPENAI_MODEL}
  maxTokens: ${OPENAI_MAX_TOKENS}
  temperature: ${OPENAI_TEMPERATURE}

# Proxy para OpenAI
proxy:
  '/openai':
    target: 'https://api.openai.com/v1'
    changeOrigin: true
    headers:
      Authorization: 'Bearer ${OPENAI_API_KEY}'
    pathRewrite:
      '^/openai': ''

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

scaffolder:
  defaultAuthor:
    name: IA-Ops Platform
    email: noreply@ia-ops.local

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

# Crear plugin personalizado de OpenAI
echo "🔌 Creando plugin de OpenAI..."
mkdir -p openai-plugin

cat > openai-plugin/package.json << 'EOF'
{
  "name": "@internal/plugin-openai",
  "version": "0.1.0",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "license": "Apache-2.0",
  "dependencies": {
    "@backstage/core-components": "^0.14.10",
    "@backstage/core-plugin-api": "^1.9.3",
    "@backstage/theme": "^0.5.6",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "@backstage/cli": "^0.33.1"
  },
  "files": [
    "dist"
  ]
}
EOF

cat > openai-plugin/src/index.ts << 'EOF'
export { openaiPlugin, OpenAIPage } from './plugin';
EOF

cat > openai-plugin/src/plugin.tsx << 'EOF'
import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';

import { rootRouteRef } from './routes';

export const openaiPlugin = createPlugin({
  id: 'openai',
  routes: {
    root: rootRouteRef,
  },
});

export const OpenAIPage = openaiPlugin.provide(
  createRoutableExtension({
    name: 'OpenAIPage',
    component: () =>
      import('./components/OpenAIPage').then(m => m.OpenAIPage),
    mountPoint: rootRouteRef,
  }),
);
EOF

cat > openai-plugin/src/routes.ts << 'EOF'
import { createRouteRef } from '@backstage/core-plugin-api';

export const rootRouteRef = createRouteRef({
  id: 'openai',
});
EOF

mkdir -p openai-plugin/src/components

cat > openai-plugin/src/components/OpenAIPage.tsx << 'EOF'
import React, { useState } from 'react';
import {
  Page,
  Header,
  Content,
  ContentHeader,
} from '@backstage/core-components';
import { Grid, Card, CardContent, TextField, Button, Typography, Box } from '@material-ui/core';

export const OpenAIPage = () => {
  const [prompt, setPrompt] = useState('');
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    if (!prompt.trim()) return;
    
    setLoading(true);
    try {
      const res = await fetch('/api/proxy/openai/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages: [
            {
              role: 'user',
              content: prompt
            }
          ],
          max_tokens: 2000,
          temperature: 0.7
        }),
      });
      
      const data = await res.json();
      setResponse(data.choices?.[0]?.message?.content || 'No response');
    } catch (error) {
      setResponse('Error: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Page themeId="tool">
      <Header title="OpenAI Assistant" subtitle="AI-powered assistance for your development workflow" />
      <Content>
        <ContentHeader title="Chat with AI">
          <Typography variant="body1">
            Ask questions about your code, architecture, or get help with development tasks.
          </Typography>
        </ContentHeader>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Box mb={2}>
                  <TextField
                    fullWidth
                    multiline
                    rows={4}
                    variant="outlined"
                    label="Ask the AI assistant..."
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    placeholder="Example: How can I optimize this React component?"
                  />
                </Box>
                <Button
                  variant="contained"
                  color="primary"
                  onClick={handleSubmit}
                  disabled={loading || !prompt.trim()}
                >
                  {loading ? 'Thinking...' : 'Ask AI'}
                </Button>
              </CardContent>
            </Card>
          </Grid>
          {response && (
            <Grid item xs={12}>
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    AI Response:
                  </Typography>
                  <Typography variant="body1" component="pre" style={{ whiteSpace: 'pre-wrap' }}>
                    {response}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          )}
        </Grid>
      </Content>
    </Page>
  );
};
EOF

# Crear Dockerfile con plugin de OpenAI
echo "🐳 Creando Dockerfile con OpenAI..."
cat > Dockerfile.backstage-openai << 'EOF'
FROM node:18-bullseye-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    python3 \
    g++ \
    make \
    git \
    curl \
    netcat \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar Backstage CLI
RUN npm install -g @backstage/create-app@latest

# Crear aplicación Backstage
RUN npx @backstage/create-app@latest --skip-install backstage-app

WORKDIR /app/backstage-app

# Copiar plugin de OpenAI
COPY openai-plugin ./plugins/openai

# Instalar dependencias
RUN yarn install

# Agregar plugin al app
RUN cd packages/app && \
    yarn add @internal/plugin-openai@file:../../plugins/openai

# Copiar configuración
COPY app-config.openai.yaml ./app-config.yaml
COPY catalog-info.yaml ./
COPY users.yaml ./

# Modificar App.tsx para incluir el plugin
RUN sed -i '/import { CatalogGraphPage } from/a import { OpenAIPage } from "@internal/plugin-openai";' packages/app/src/App.tsx && \
    sed -i '/<Route path="\/catalog-graph" element={<CatalogGraphPage \/>} \/>/a \    <Route path="/openai" element={<OpenAIPage />} />' packages/app/src/App.tsx

# Modificar sidebar para incluir OpenAI
RUN sed -i '/import { SearchIcon } from/a import SmartToyIcon from "@material-ui/icons/SmartToy";' packages/app/src/components/Root/Root.tsx && \
    sed -i '/<SidebarItem icon={SearchIcon} to="search" text="Search" \/>/a \    <SidebarItem icon={SmartToyIcon} to="openai" text="AI Assistant" />' packages/app/src/components/Root/Root.tsx

# Exponer puertos
EXPOSE 3000 7007

# Script de inicio
COPY start-backstage-openai.sh ./
RUN chmod +x start-backstage-openai.sh

CMD ["./start-backstage-openai.sh"]
EOF

# Crear script de inicio
cat > start-backstage-openai.sh << 'EOF'
#!/bin/bash

echo "🤖 Iniciando Backstage con OpenAI..."

# Esperar PostgreSQL
echo "⏳ Esperando PostgreSQL..."
while ! nc -z localhost 5432; do
  sleep 1
done

echo "✅ PostgreSQL listo"

# Iniciar backend en background
echo "🔧 Iniciando backend..."
yarn workspace backend start &

# Esperar que el backend esté listo
sleep 30

# Iniciar frontend
echo "🎭 Iniciando frontend..."
yarn workspace app start
EOF

chmod +x start-backstage-openai.sh

# Construir y ejecutar contenedor
echo "🏗️  Construyendo imagen con OpenAI..."
docker build -f Dockerfile.backstage-openai -t backstage-openai .

echo "🚀 Iniciando Backstage con OpenAI..."
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
  -e OPENAI_MODEL=$OPENAI_MODEL \
  -e OPENAI_MAX_TOKENS=$OPENAI_MAX_TOKENS \
  -e OPENAI_TEMPERATURE=$OPENAI_TEMPERATURE \
  -p 3000:3000 \
  -p 7007:7007 \
  backstage-openai

echo "⏳ Esperando Backstage con OpenAI (esto puede tomar varios minutos)..."
sleep 120

# Verificar servicios
echo "✅ Verificando servicios..."

if curl -s -f "http://localhost:7007/api/catalog/entities" >/dev/null 2>&1; then
    echo "✅ Backend funcionando: http://localhost:7007"
else
    echo "⚠️  Backend puede estar iniciando..."
fi

if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    echo "✅ Frontend funcionando: http://localhost:3000"
else
    echo "⚠️  Frontend puede estar iniciando..."
fi

echo ""
echo "🎉 Backstage con OpenAI debería estar funcionando en:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:7007"
echo "   AI Assistant: http://localhost:3000/openai"
echo ""
echo "🤖 Funcionalidades de OpenAI disponibles:"
echo "   - Chat con IA en /openai"
echo "   - Proxy API en /api/proxy/openai"
echo "   - Integración con catálogo"
echo ""
echo "Para ver logs: docker logs -f ia-ops-backstage"
