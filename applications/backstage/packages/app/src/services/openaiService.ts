import { DEFAULT_CONFIG, isDevelopment } from '../config/env';

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
    // Configuración usando constantes del archivo env.ts
    // Esto evita problemas con process.env en el navegador
    this.config = {
      apiKey: DEFAULT_CONFIG.apiKey,
      model: DEFAULT_CONFIG.model,
      maxTokens: DEFAULT_CONFIG.maxTokens,
      temperature: DEFAULT_CONFIG.temperature,
    };

    // Intentar cargar configuración desde localStorage si existe (esto sobrescribirá la configuración por defecto)
    this.loadConfigFromStorage();

    // Log para debugging (solo en desarrollo)
    if (isDevelopment()) {
      // eslint-disable-next-line no-console
      console.log('🤖 OpenAI Service initialized from environment constants:', {
        hasApiKey: !!this.config.apiKey,
        apiKeyPreview: this.config.apiKey ? `${this.config.apiKey.substring(0, 20)}...` : 'No API key',
        model: this.config.model,
        maxTokens: this.config.maxTokens,
        temperature: this.config.temperature,
        envSource: 'Environment constants (no process.env dependency)'
      });
    }
  }

  private loadConfigFromStorage() {
    try {
      const storedConfig = localStorage.getItem('openai-config');
      if (storedConfig) {
        const parsed = JSON.parse(storedConfig);
        this.config = { ...this.config, ...parsed };
      }
    } catch (error) {
      // Error de localStorage manejado silenciosamente
    }
  }

  public updateConfig(newConfig: Partial<OpenAIConfig>) {
    this.config = { ...this.config, ...newConfig };
    try {
      localStorage.setItem('openai-config', JSON.stringify(this.config));
    } catch (error) {
      // Error de localStorage manejado silenciosamente
    }
  }

  async sendMessage(messages: ChatMessage[]): Promise<string> {
    // Si no hay API key, devolver respuesta simulada
    if (!this.config.apiKey || this.config.apiKey === 'sk-your-openai-api-key-here') {
      return this.getSimulatedResponse(messages[messages.length - 1].content);
    }

    try {
      const response = await fetch(`${this.baseURL}/chat/completions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.config.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: this.config.model,
          messages: [
            {
              role: 'system',
              content: `Eres un asistente de IA especializado en Backstage, desarrollo de software y DevOps. 
                       
                       CONTEXTO: Estás integrado en una plataforma Backstage y ayudas a desarrolladores con:
                       
                       🎭 BACKSTAGE:
                       - Software Catalog (catalog-info.yaml, entidades, componentes, APIs, recursos)
                       - TechDocs (documentación como código con MkDocs)
                       - Scaffolder (templates para generar proyectos)
                       - Plugins y configuración (app-config.yaml)
                       - Integración con GitHub, Kubernetes, etc.
                       
                       🛠️ DESARROLLO:
                       - GitHub Actions y CI/CD
                       - Kubernetes y contenedores
                       - Mejores prácticas de desarrollo
                       - Arquitectura de software
                       - Monitoreo y observabilidad
                       
                       📋 INSTRUCCIONES:
                       - Responde de manera concisa pero completa
                       - Incluye ejemplos de código cuando sea relevante
                       - Sugiere mejores prácticas
                       - Si no sabes algo específico, admítelo y sugiere dónde buscar
                       - Usa emojis para hacer las respuestas más amigables
                       - Responde en español
                       
                       ¡Estoy aquí para ayudarte a aprovechar al máximo Backstage y mejorar tu flujo de desarrollo!`
            },
            ...messages
          ],
          max_tokens: this.config.maxTokens,
          temperature: this.config.temperature,
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return data.choices[0]?.message?.content || 'Lo siento, no pude generar una respuesta.';
    } catch (error) {
      // Error de API manejado silenciosamente - se devuelve respuesta simulada
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
    
    if (message.includes('error') || message.includes('problema')) {
      return '🔧 Para resolver errores en Backstage: 1) Revisa los logs del backend, 2) Verifica la configuración en app-config.yaml, 3) Asegúrate de que las variables de entorno estén configuradas. ¿Qué error específico estás viendo?';
    }
    
    if (message.includes('configurar') || message.includes('setup')) {
      return '⚙️ Para configurar Backstage correctamente: 1) Configura las variables de entorno, 2) Ajusta app-config.yaml, 3) Instala los plugins necesarios, 4) Configura la base de datos. ¿Qué componente necesitas configurar?';
    }
    
    // Respuestas generales
    const responses = [
      `Interesante pregunta sobre "${userMessage}". En el contexto de Backstage y desarrollo, te recomiendo revisar la documentación oficial o explorar los plugins disponibles.`,
      `Para "${userMessage}", te sugiero verificar la configuración en app-config.yaml o consultar los logs del backend para más detalles.`,
      `Sobre "${userMessage}", ¿has revisado el Software Catalog? Muchas veces la información que buscas está registrada ahí.`,
      `Respecto a "${userMessage}", considera usar el Scaffolder para automatizar tareas repetitivas o crear templates personalizados.`,
      `Para "${userMessage}", puedes encontrar más información en la documentación de Backstage o en la comunidad. ¿Necesitas ayuda con algo específico?`
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
