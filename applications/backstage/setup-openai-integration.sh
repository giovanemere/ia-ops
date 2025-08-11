#!/bin/bash

echo "🔑 CONFIGURACIÓN DE INTEGRACIÓN CON OPENAI"
echo "=========================================="

echo ""
echo "🎯 OBJETIVO:"
echo "============"
echo "• Integrar AI Chat con OpenAI API"
echo "• Configurar variables de entorno"
echo "• Crear servicio de IA"
echo "• Actualizar componente de chat"

echo ""
echo "📋 PASO 1: CONFIGURAR VARIABLES DE ENTORNO"
echo "=========================================="

# Agregar variables de OpenAI al archivo .env
echo "🔧 Agregando variables de OpenAI a ../../.env..."

# Verificar si ya existen las variables
if grep -q "OPENAI_API_KEY" ../../.env; then
    echo "✅ Variables de OpenAI ya existen en .env"
else
    echo "" >> ../../.env
    echo "# OpenAI Configuration for AI Chat" >> ../../.env
    echo "OPENAI_API_KEY=sk-your-openai-api-key-here" >> ../../.env
    echo "OPENAI_MODEL=gpt-3.5-turbo" >> ../../.env
    echo "OPENAI_MAX_TOKENS=150" >> ../../.env
    echo "OPENAI_TEMPERATURE=0.7" >> ../../.env
    echo "✅ Variables de OpenAI agregadas a .env"
fi

echo ""
echo "📦 PASO 2: INSTALAR DEPENDENCIAS"
echo "==============================="

echo "🔧 Instalando dependencias necesarias..."

# Cambiar al directorio de la app
cd packages/app

# Instalar axios para hacer requests HTTP
if ! grep -q "axios" package.json; then
    echo "📦 Instalando axios..."
    npm install axios
    echo "✅ Axios instalado"
else
    echo "✅ Axios ya está instalado"
fi

# Volver al directorio principal
cd ../..

echo ""
echo "🔧 PASO 3: CREAR SERVICIO DE OPENAI"
echo "=================================="

# Crear directorio para servicios
mkdir -p packages/app/src/services

# Crear servicio de OpenAI
cat > packages/app/src/services/openaiService.ts << 'EOF'
import axios from 'axios';

export interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export interface OpenAIConfig {
  apiKey: string;
  model: string;
  maxTokens: number;
  temperature: number;
}

class OpenAIService {
  private config: OpenAIConfig;
  private baseURL = 'https://api.openai.com/v1';

  constructor() {
    // En un entorno real, estas variables vendrían del backend por seguridad
    this.config = {
      apiKey: process.env.REACT_APP_OPENAI_API_KEY || '',
      model: process.env.REACT_APP_OPENAI_MODEL || 'gpt-3.5-turbo',
      maxTokens: parseInt(process.env.REACT_APP_OPENAI_MAX_TOKENS || '150'),
      temperature: parseFloat(process.env.REACT_APP_OPENAI_TEMPERATURE || '0.7'),
    };
  }

  async sendMessage(messages: ChatMessage[]): Promise<string> {
    // Si no hay API key, devolver respuesta simulada
    if (!this.config.apiKey || this.config.apiKey === 'sk-your-openai-api-key-here') {
      return this.getSimulatedResponse(messages[messages.length - 1].content);
    }

    try {
      const response = await axios.post(
        `${this.baseURL}/chat/completions`,
        {
          model: this.config.model,
          messages: [
            {
              role: 'system',
              content: `Eres un asistente de IA especializado en Backstage, desarrollo de software y DevOps. 
                       Ayudas a los desarrolladores con preguntas sobre:
                       - Backstage y sus plugins
                       - Software Catalog
                       - TechDocs
                       - Scaffolder templates
                       - GitHub Actions
                       - Kubernetes
                       - Mejores prácticas de desarrollo
                       
                       Responde de manera concisa y útil.`
            },
            ...messages
          ],
          max_tokens: this.config.maxTokens,
          temperature: this.config.temperature,
        },
        {
          headers: {
            'Authorization': `Bearer ${this.config.apiKey}`,
            'Content-Type': 'application/json',
          },
        }
      );

      return response.data.choices[0]?.message?.content || 'Lo siento, no pude generar una respuesta.';
    } catch (error) {
      console.error('Error calling OpenAI API:', error);
      return this.getSimulatedResponse(messages[messages.length - 1].content);
    }
  }

  private getSimulatedResponse(userMessage: string): string {
    const message = userMessage.toLowerCase();
    
    // Respuestas específicas para Backstage
    if (message.includes('backstage')) {
      return '🎭 Backstage es una plataforma de portal para desarrolladores creada por Spotify. Te ayuda a centralizar herramientas, servicios y documentación. ¿Qué aspecto específico te interesa?';
    }
    
    if (message.includes('catalog') || message.includes('catálogo')) {
      return '📊 El Software Catalog es el corazón de Backstage. Permite registrar y descubrir componentes, APIs, recursos y más. Puedes agregar entidades usando catalog-info.yaml. ¿Necesitas ayuda con algún tipo específico de entidad?';
    }
    
    if (message.includes('plugin')) {
      return '🔌 Los plugins extienden la funcionalidad de Backstage. Hay plugins para GitHub, Kubernetes, TechDocs, y muchos más. ¿Qué plugin te interesa instalar o configurar?';
    }
    
    if (message.includes('techdocs')) {
      return '📚 TechDocs permite escribir documentación como código usando Markdown. Se integra con tu repositorio y se renderiza automáticamente. ¿Quieres saber cómo configurarlo?';
    }
    
    if (message.includes('template') || message.includes('scaffolder')) {
      return '🏗️ El Scaffolder permite crear templates para generar nuevos proyectos automáticamente. Usa archivos template.yaml para definir la estructura. ¿Necesitas ayuda creando un template?';
    }
    
    if (message.includes('github')) {
      return '🐙 La integración con GitHub permite mostrar información de repositorios, PRs, Actions y más. Necesitas configurar GITHUB_TOKEN y las anotaciones correctas. ¿Qué aspecto de GitHub quieres integrar?';
    }
    
    if (message.includes('kubernetes') || message.includes('k8s')) {
      return '☸️ Backstage puede mostrar información de Kubernetes como deployments, pods, servicios. Hay plugins específicos para diferentes proveedores. ¿Usas algún proveedor específico?';
    }
    
    // Respuestas generales
    const responses = [
      `Interesante pregunta sobre "${userMessage}". En el contexto de Backstage y desarrollo, te recomiendo revisar la documentación oficial o explorar los plugins disponibles.`,
      `Para "${userMessage}", te sugiero verificar la configuración en app-config.yaml o consultar los logs del backend para más detalles.`,
      `Sobre "${userMessage}", ¿has revisado el Software Catalog? Muchas veces la información que buscas está registrada ahí.`,
      `Respecto a "${userMessage}", considera usar el Scaffolder para automatizar tareas repetitivas o crear templates personalizados.`
    ];
    
    return responses[Math.floor(Math.random() * responses.length)];
  }

  isConfigured(): boolean {
    return !!(this.config.apiKey && this.config.apiKey !== 'sk-your-openai-api-key-here');
  }

  getConfig(): Partial<OpenAIConfig> {
    return {
      model: this.config.model,
      maxTokens: this.config.maxTokens,
      temperature: this.config.temperature,
    };
  }
}

export const openaiService = new OpenAIService();
EOF

echo "✅ Servicio de OpenAI creado"

echo ""
echo "📝 PASO 4: CONFIGURAR VARIABLES DE ENTORNO PARA REACT"
echo "===================================================="

# Crear archivo .env.local para React (variables que empiecen con REACT_APP_)
cat > packages/app/.env.local << 'EOF'
# OpenAI Configuration for React App
# IMPORTANTE: En producción, estas variables deberían manejarse desde el backend por seguridad
REACT_APP_OPENAI_MODEL=gpt-3.5-turbo
REACT_APP_OPENAI_MAX_TOKENS=150
REACT_APP_OPENAI_TEMPERATURE=0.7

# NO pongas tu API key real aquí en desarrollo
# REACT_APP_OPENAI_API_KEY=sk-your-real-api-key-here
EOF

echo "✅ Variables de entorno para React configuradas"

echo ""
echo "✅ CONFIGURACIÓN DE OPENAI COMPLETADA:"
echo "====================================="
echo "• ✅ Variables agregadas a ../../.env"
echo "• ✅ Dependencia axios instalada"
echo "• ✅ Servicio OpenAI creado"
echo "• ✅ Variables de React configuradas"

echo ""
echo "🔑 CONFIGURACIÓN DE API KEY:"
echo "=========================="
echo "Para usar OpenAI real:"
echo "1. 🌐 Ve a: https://platform.openai.com/api-keys"
echo "2. 🔑 Crea una nueva API key"
echo "3. 📝 Edita packages/app/.env.local:"
echo "   REACT_APP_OPENAI_API_KEY=tu-api-key-real"
echo ""
echo "⚠️  IMPORTANTE: Por seguridad, en producción maneja"
echo "   las API keys desde el backend, no desde el frontend"

echo ""
echo "🚀 PRÓXIMO PASO:"
echo "==============="
echo "Ejecutar: ./enhance-ai-chat-ui.sh"
echo "Para actualizar la interfaz y usar el nuevo servicio"
