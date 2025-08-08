# Dockerfile limpio para Backstage Mock Backend
FROM node:18-alpine

RUN apk add --no-cache curl

WORKDIR /app

# Crear servidor mock funcional
RUN echo "const http = require('http');" > server.js && \
    echo "const url = require('url');" >> server.js && \
    echo "" >> server.js && \
    echo "const server = http.createServer((req, res) => {" >> server.js && \
    echo "  const parsedUrl = url.parse(req.url, true);" >> server.js && \
    echo "  " >> server.js && \
    echo "  res.setHeader('Content-Type', 'application/json');" >> server.js && \
    echo "  res.setHeader('Access-Control-Allow-Origin', '*');" >> server.js && \
    echo "  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');" >> server.js && \
    echo "  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');" >> server.js && \
    echo "  " >> server.js && \
    echo "  if (req.method === 'OPTIONS') {" >> server.js && \
    echo "    res.writeHead(200);" >> server.js && \
    echo "    res.end();" >> server.js && \
    echo "    return;" >> server.js && \
    echo "  }" >> server.js && \
    echo "  " >> server.js && \
    echo "  if (parsedUrl.pathname === '/api/catalog/health') {" >> server.js && \
    echo "    res.writeHead(200);" >> server.js && \
    echo "    res.end(JSON.stringify({" >> server.js && \
    echo "      status: 'ok'," >> server.js && \
    echo "      service: 'backstage-mock'," >> server.js && \
    echo "      timestamp: new Date().toISOString()" >> server.js && \
    echo "    }));" >> server.js && \
    echo "  } else if (parsedUrl.pathname === '/api/catalog/entities') {" >> server.js && \
    echo "    res.writeHead(200);" >> server.js && \
    echo "    res.end(JSON.stringify({" >> server.js && \
    echo "      items: [" >> server.js && \
    echo "        {" >> server.js && \
    echo "          apiVersion: 'backstage.io/v1alpha1'," >> server.js && \
    echo "          kind: 'Component'," >> server.js && \
    echo "          metadata: { name: 'openai-service', title: 'OpenAI Service' }," >> server.js && \
    echo "          spec: { type: 'service', lifecycle: 'production' }" >> server.js && \
    echo "        }" >> server.js && \
    echo "      ]" >> server.js && \
    echo "    }));" >> server.js && \
    echo "  } else {" >> server.js && \
    echo "    res.writeHead(200);" >> server.js && \
    echo "    res.end(JSON.stringify({" >> server.js && \
    echo "      message: 'Backstage Mock Backend'," >> server.js && \
    echo "      version: '1.0.0'," >> server.js && \
    echo "      path: parsedUrl.pathname" >> server.js && \
    echo "    }));" >> server.js && \
    echo "  }" >> server.js && \
    echo "});" >> server.js && \
    echo "" >> server.js && \
    echo "const port = process.env.PORT || 7007;" >> server.js && \
    echo "server.listen(port, '0.0.0.0', () => {" >> server.js && \
    echo "  console.log('🚀 Backstage Mock Backend running on port', port);" >> server.js && \
    echo "});" >> server.js

RUN addgroup -g 1001 -S backstage && adduser -S backstage -u 1001
RUN chown -R backstage:backstage /app

USER backstage

EXPOSE 7007

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:7007/api/catalog/health || exit 1

CMD ["node", "server.js"]
