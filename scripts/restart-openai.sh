#!/bin/bash

echo "🔄 Reiniciando OpenAI Service..."
cd ia-ops-openai
docker-compose -f docker-compose.integrated.yml restart
echo "✅ OpenAI Service reiniciado"
