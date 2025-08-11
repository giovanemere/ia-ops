"""
LangChain Service Simplificado para IA-Ops Platform
Versión compatible con las nuevas versiones de LangChain
"""

import os
import logging
from typing import Dict, List, Optional, Any
from langchain_openai import ChatOpenAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.schema import BaseMessage, HumanMessage, SystemMessage
import structlog

logger = structlog.get_logger(__name__)

class SimpleLangChainService:
    """
    Servicio simplificado de LangChain para orquestación de LLMs
    """
    
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")
        self.model_name = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        self.max_tokens = int(os.getenv("OPENAI_MAX_TOKENS", "150"))
        self.temperature = float(os.getenv("OPENAI_TEMPERATURE", "0.7"))
        
        # Inicializar modelo
        self._init_model()
        
        logger.info("Simple LangChain Service initialized", 
                   model=self.model_name, 
                   max_tokens=self.max_tokens,
                   temperature=self.temperature)
    
    def _init_model(self):
        """Inicializar modelo de LangChain"""
        try:
            if self.api_key:
                self.chat_model = ChatOpenAI(
                    api_key=self.api_key,
                    model=self.model_name,
                    max_tokens=self.max_tokens,
                    temperature=self.temperature
                )
                logger.info("LangChain ChatOpenAI model initialized successfully")
            else:
                self.chat_model = None
                logger.warning("No OpenAI API key provided, running in demo mode")
                
        except Exception as e:
            logger.error("Failed to initialize LangChain model", error=str(e))
            self.chat_model = None
    
    async def analyze_code(self, code_content: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analizar código usando LangChain
        """
        try:
            if not self.chat_model:
                return self._get_demo_analysis()
            
            # Prompt para análisis de código
            prompt_template = """
            Eres un arquitecto de software experto. Analiza el siguiente código:

            **CÓDIGO:**
            ```
            {code_content}
            ```

            **METADATOS:**
            {metadata}

            Proporciona un análisis técnico que incluya:
            1. **Tecnologías identificadas**
            2. **Patrón arquitectónico**
            3. **Componentes principales**
            4. **Recomendaciones de mejora**

            **Análisis:**
            """
            
            # Crear el prompt
            messages = [
                HumanMessage(content=prompt_template.format(
                    code_content=code_content,
                    metadata=str(metadata)
                ))
            ]
            
            # Ejecutar análisis
            result = await self.chat_model.ainvoke(messages)
            
            return {
                "analysis": result.content,
                "metadata": {
                    "tokens_used": result.usage_metadata.get("total_tokens", 0) if hasattr(result, 'usage_metadata') else 0,
                    "cost": 0.0,  # Calcular según el modelo
                    "model": self.model_name
                }
            }
            
        except Exception as e:
            logger.error("Code analysis failed", error=str(e))
            return self._get_demo_analysis()
    
    async def recommend_architecture(self, code_analysis: str, reference_architectures: List[str], 
                                   project_requirements: str) -> Dict[str, Any]:
        """
        Recomendar arquitectura usando LangChain
        """
        try:
            if not self.chat_model:
                return self._get_demo_architecture()
            
            prompt_template = """
            Basándote en el análisis de código, recomienda la mejor arquitectura:

            **ANÁLISIS DE CÓDIGO:**
            {code_analysis}

            **ARQUITECTURAS DISPONIBLES:**
            {reference_architectures}

            **REQUISITOS:**
            {project_requirements}

            Proporciona:
            1. **Arquitectura recomendada**
            2. **Justificación técnica**
            3. **Diagrama Mermaid**
            4. **Plan de implementación**

            **Recomendación:**
            """
            
            messages = [
                HumanMessage(content=prompt_template.format(
                    code_analysis=code_analysis,
                    reference_architectures="\n".join(reference_architectures),
                    project_requirements=project_requirements
                ))
            ]
            
            result = await self.chat_model.ainvoke(messages)
            
            return {
                "recommendation": result.content,
                "metadata": {
                    "tokens_used": result.usage_metadata.get("total_tokens", 0) if hasattr(result, 'usage_metadata') else 0,
                    "cost": 0.0,
                    "model": self.model_name
                }
            }
            
        except Exception as e:
            logger.error("Architecture recommendation failed", error=str(e))
            return self._get_demo_architecture()
    
    async def generate_documentation(self, code_analysis: str, architecture_recommendation: str, 
                                   doc_type: str = "README") -> Dict[str, Any]:
        """
        Generar documentación usando LangChain
        """
        try:
            if not self.chat_model:
                return self._get_demo_documentation()
            
            prompt_template = """
            Genera documentación técnica completa en formato Markdown:

            **ANÁLISIS DE CÓDIGO:**
            {code_analysis}

            **ARQUITECTURA RECOMENDADA:**
            {architecture_recommendation}

            **TIPO DE DOCUMENTACIÓN:** {doc_type}

            Genera un {doc_type} completo que incluya:
            1. **Descripción del proyecto**
            2. **Arquitectura y diagramas**
            3. **Instalación y configuración**
            4. **Uso y ejemplos**
            5. **API documentation**
            6. **Deployment**

            **Documentación:**
            """
            
            messages = [
                HumanMessage(content=prompt_template.format(
                    code_analysis=code_analysis,
                    architecture_recommendation=architecture_recommendation,
                    doc_type=doc_type
                ))
            ]
            
            result = await self.chat_model.ainvoke(messages)
            
            return {
                "documentation": result.content,
                "metadata": {
                    "tokens_used": result.usage_metadata.get("total_tokens", 0) if hasattr(result, 'usage_metadata') else 0,
                    "cost": 0.0,
                    "model": self.model_name
                }
            }
            
        except Exception as e:
            logger.error("Documentation generation failed", error=str(e))
            return self._get_demo_documentation()
    
    async def chat_completion(self, user_input: str) -> Dict[str, Any]:
        """
        Chat conversacional usando LangChain
        """
        try:
            if not self.chat_model:
                return self._get_demo_chat_response(user_input)
            
            messages = [
                SystemMessage(content="Eres un asistente DevOps experto especializado en análisis de código, arquitecturas de software y documentación técnica."),
                HumanMessage(content=user_input)
            ]
            
            result = await self.chat_model.ainvoke(messages)
            
            return {
                "response": result.content,
                "metadata": {
                    "tokens_used": result.usage_metadata.get("total_tokens", 0) if hasattr(result, 'usage_metadata') else 0,
                    "cost": 0.0,
                    "model": self.model_name
                }
            }
            
        except Exception as e:
            logger.error("Chat completion failed", error=str(e))
            return self._get_demo_chat_response(user_input)
    
    def _get_demo_analysis(self) -> Dict[str, Any]:
        """Respuesta demo para análisis de código"""
        return {
            "analysis": """
            ## 🔍 Análisis de Código (Modo Demo)
            
            ### 🛠️ Tecnologías Identificadas
            - **Framework**: Node.js + Express
            - **Base de datos**: PostgreSQL
            - **Frontend**: React 18
            - **Testing**: Jest
            
            ### 🏗️ Patrón Arquitectónico
            - **Tipo**: API-First Microservice
            - **Estructura**: MVC con separación de responsabilidades
            - **Escalabilidad**: Horizontal ready
            
            ### 📦 Componentes Principales
            - **Controllers**: Manejo de rutas HTTP
            - **Services**: Lógica de negocio
            - **Models**: Acceso a datos
            - **Middleware**: Autenticación y validación
            
            ### 💡 Recomendaciones
            1. **Testing**: Implementar tests unitarios y de integración
            2. **Documentación**: Agregar OpenAPI/Swagger
            3. **Monitoreo**: Configurar métricas y logging
            4. **Seguridad**: Implementar rate limiting y validación
            """,
            "metadata": {
                "tokens_used": 0,
                "cost": 0.0,
                "model": "demo-mode"
            }
        }
    
    def _get_demo_architecture(self) -> Dict[str, Any]:
        """Respuesta demo para recomendación arquitectónica"""
        return {
            "recommendation": """
            ## 🏗️ Recomendación Arquitectónica (Modo Demo)
            
            ### 🎯 Arquitectura Recomendada
            **Microservicios con API Gateway**
            
            ### 📋 Justificación Técnica
            - **Escalabilidad**: Servicios independientes
            - **Mantenibilidad**: Separación de responsabilidades
            - **Flexibilidad**: Tecnologías heterogéneas
            - **Resilencia**: Fallos aislados
            
            ### 📊 Diagrama de Arquitectura
            ```mermaid
            graph TB
                A[API Gateway] --> B[Auth Service]
                A --> C[Business Service]
                A --> D[Data Service]
                B --> E[(Auth DB)]
                C --> F[(Business DB)]
                D --> G[(Data DB)]
                
                H[Load Balancer] --> A
                I[Monitoring] --> A
                I --> B
                I --> C
                I --> D
            ```
            
            ### 🚀 Plan de Implementación
            1. **Fase 1**: Extraer servicios por dominio
            2. **Fase 2**: Implementar API Gateway
            3. **Fase 3**: Configurar service discovery
            4. **Fase 4**: Migrar datos gradualmente
            5. **Fase 5**: Implementar monitoreo
            """,
            "metadata": {
                "tokens_used": 0,
                "cost": 0.0,
                "model": "demo-mode"
            }
        }
    
    def _get_demo_documentation(self) -> Dict[str, Any]:
        """Respuesta demo para documentación"""
        return {
            "documentation": """
            # 📚 Proyecto Demo - Documentación Automática
            
            ## 📋 Descripción
            Aplicación web moderna con arquitectura de microservicios, diseñada para alta escalabilidad y mantenibilidad.
            
            ## 🏗️ Arquitectura
            Sistema distribuido con API Gateway y servicios especializados por dominio de negocio.
            
            ## 🛠️ Stack Tecnológico
            
            ### Backend
            - **Runtime**: Node.js 18+
            - **Framework**: Express.js
            - **Base de Datos**: PostgreSQL 15
            - **Cache**: Redis 7
            
            ### Frontend
            - **Framework**: React 18
            - **UI Library**: Material-UI
            - **State Management**: Redux Toolkit
            
            ### DevOps
            - **Containerización**: Docker
            - **Orquestación**: Kubernetes
            - **CI/CD**: GitHub Actions
            - **Monitoreo**: Prometheus + Grafana
            
            ## 🚀 Instalación
            
            ### Prerrequisitos
            ```bash
            node >= 18.0.0
            docker >= 20.0.0
            docker-compose >= 2.0.0
            ```
            
            ### Instalación Local
            ```bash
            # 1. Clonar repositorio
            git clone <repository-url>
            cd <project-name>
            
            # 2. Configurar variables de entorno
            cp .env.example .env
            # Editar .env con tus configuraciones
            
            # 3. Instalar dependencias
            npm install
            
            # 4. Inicializar base de datos
            npm run db:migrate
            
            # 5. Iniciar servicios
            docker-compose up -d
            npm start
            ```
            
            ## 📡 API Endpoints
            
            ### Autenticación
            ```http
            POST /api/auth/login
            POST /api/auth/register
            GET  /api/auth/profile
            ```
            
            ### Recursos Principales
            ```http
            GET    /api/resources
            POST   /api/resources
            GET    /api/resources/:id
            PUT    /api/resources/:id
            DELETE /api/resources/:id
            ```
            
            ## 🚢 Deployment
            
            ### Docker Compose (Desarrollo)
            ```bash
            docker-compose up -d
            ```
            
            ### Kubernetes (Producción)
            ```bash
            kubectl apply -f k8s/
            ```
            
            ## 📊 Monitoreo
            - **Métricas**: http://localhost:9090 (Prometheus)
            - **Dashboards**: http://localhost:3001 (Grafana)
            - **Logs**: `docker-compose logs -f`
            
            ## 🤝 Contribución
            1. Fork del repositorio
            2. Crear feature branch
            3. Commit cambios
            4. Crear Pull Request
            
            ---
            
            **Generado automáticamente por IA-Ops Platform** 🤖
            """,
            "metadata": {
                "tokens_used": 0,
                "cost": 0.0,
                "model": "demo-mode"
            }
        }
    
    def _get_demo_chat_response(self, user_input: str) -> Dict[str, Any]:
        """Respuesta demo para chat"""
        return {
            "response": f"""
            ¡Hola! 👋 Soy tu **Asistente DevOps con IA** (modo demo).
            
            **Tu pregunta:** "{user_input}"
            
            🛠️ **Puedo ayudarte con:**
            - 🔍 Análisis de código y arquitecturas
            - 📚 Generación de documentación técnica
            - 💡 Recomendaciones de mejores prácticas
            - 🚀 Estrategias de deployment y CI/CD
            - 🏗️ Diseño de arquitecturas de software
            - 📊 Optimización de performance
            
            🔑 **Para funcionalidad completa:**
            Configura tu API key de OpenAI en las variables de entorno.
            
            ¿En qué más puedo ayudarte? 🚀
            """,
            "metadata": {
                "tokens_used": 0,
                "cost": 0.0,
                "model": "demo-mode"
            }
        }

# Instancia global del servicio
simple_langchain_service = SimpleLangChainService()
