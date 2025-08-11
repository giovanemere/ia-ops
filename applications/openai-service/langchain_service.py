"""
LangChain Service para IA-Ops Platform
Orquestación de LLMs para análisis de código y generación de documentación
"""

import os
import logging
from typing import Dict, List, Optional, Any
from langchain.llms import OpenAI
from langchain.chat_models import ChatOpenAI
from langchain.schema import BaseMessage, HumanMessage, SystemMessage
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate, ChatPromptTemplate
from langchain.memory import ConversationBufferMemory
from langchain.callbacks import get_openai_callback
import structlog

logger = structlog.get_logger(__name__)

class LangChainService:
    """
    Servicio principal de LangChain para orquestación de LLMs
    """
    
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")
        self.model_name = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        self.max_tokens = int(os.getenv("OPENAI_MAX_TOKENS", "150"))
        self.temperature = float(os.getenv("OPENAI_TEMPERATURE", "0.7"))
        
        # Inicializar modelos
        self._init_models()
        
        # Inicializar chains
        self._init_chains()
        
        logger.info("LangChain Service initialized", 
                   model=self.model_name, 
                   max_tokens=self.max_tokens,
                   temperature=self.temperature)
    
    def _init_models(self):
        """Inicializar modelos de LangChain"""
        try:
            # Chat model para conversaciones
            self.chat_model = ChatOpenAI(
                openai_api_key=self.api_key,
                model_name=self.model_name,
                max_tokens=self.max_tokens,
                temperature=self.temperature
            )
            
            # LLM model para completions
            self.llm_model = OpenAI(
                openai_api_key=self.api_key,
                model_name=self.model_name,
                max_tokens=self.max_tokens,
                temperature=self.temperature
            )
            
            logger.info("LangChain models initialized successfully")
            
        except Exception as e:
            logger.error("Failed to initialize LangChain models", error=str(e))
            # Fallback a modo demo
            self.chat_model = None
            self.llm_model = None
    
    def _init_chains(self):
        """Inicializar chains especializados"""
        self.chains = {}
        
        # Chain para análisis de código
        self.chains['code_analysis'] = self._create_code_analysis_chain()
        
        # Chain para recomendaciones arquitectónicas
        self.chains['architecture_recommendation'] = self._create_architecture_chain()
        
        # Chain para generación de documentación
        self.chains['documentation_generation'] = self._create_documentation_chain()
        
        # Chain para chat conversacional
        self.chains['conversational_chat'] = self._create_chat_chain()
        
        logger.info("LangChain chains initialized", chains=list(self.chains.keys()))
    
    def _create_code_analysis_chain(self) -> Optional[LLMChain]:
        """Crear chain para análisis de código"""
        try:
            prompt_template = """
            Eres un experto arquitecto de software y DevOps. Analiza el siguiente código y proporciona:

            1. **Tecnologías Identificadas**: Frameworks, librerías, lenguajes
            2. **Patrón Arquitectónico**: MVC, Microservicios, Monolito, etc.
            3. **Componentes Principales**: Servicios, controladores, modelos
            4. **Dependencias Externas**: APIs, bases de datos, servicios
            5. **Calidad del Código**: Estructura, mejores prácticas
            6. **Recomendaciones**: Mejoras sugeridas

            **Código a analizar:**
            ```
            {code_content}
            ```

            **Metadatos del proyecto:**
            {metadata}

            **Análisis:**
            """
            
            prompt = PromptTemplate(
                input_variables=["code_content", "metadata"],
                template=prompt_template
            )
            
            if self.llm_model:
                return LLMChain(llm=self.llm_model, prompt=prompt)
            return None
            
        except Exception as e:
            logger.error("Failed to create code analysis chain", error=str(e))
            return None
    
    def _create_architecture_chain(self) -> Optional[LLMChain]:
        """Crear chain para recomendaciones arquitectónicas"""
        try:
            prompt_template = """
            Eres un arquitecto de software experto. Basándote en el análisis de código, recomienda la mejor arquitectura:

            **Análisis del código:**
            {code_analysis}

            **Arquitecturas de referencia disponibles:**
            {reference_architectures}

            **Requisitos del proyecto:**
            {project_requirements}

            Proporciona:
            1. **Arquitectura Recomendada**: Nombre y tipo
            2. **Justificación**: Por qué es la mejor opción
            3. **Beneficios**: Ventajas de esta arquitectura
            4. **Consideraciones**: Aspectos a tener en cuenta
            5. **Diagrama Mermaid**: Representación visual
            6. **Estrategia de Migración**: Si aplica

            **Recomendación:**
            """
            
            prompt = PromptTemplate(
                input_variables=["code_analysis", "reference_architectures", "project_requirements"],
                template=prompt_template
            )
            
            if self.llm_model:
                return LLMChain(llm=self.llm_model, prompt=prompt)
            return None
            
        except Exception as e:
            logger.error("Failed to create architecture chain", error=str(e))
            return None
    
    def _create_documentation_chain(self) -> Optional[LLMChain]:
        """Crear chain para generación de documentación"""
        try:
            prompt_template = """
            Eres un technical writer experto. Genera documentación técnica completa basada en:

            **Análisis de código:**
            {code_analysis}

            **Arquitectura recomendada:**
            {architecture_recommendation}

            **Tipo de documentación:** {doc_type}

            Genera documentación en formato Markdown que incluya:

            1. **Descripción del Proyecto**: Propósito y funcionalidad
            2. **Arquitectura**: Diagrama y explicación
            3. **Tecnologías Utilizadas**: Stack técnico completo
            4. **Instalación y Configuración**: Pasos detallados
            5. **Uso y Ejemplos**: Casos de uso principales
            6. **API Documentation**: Si aplica
            7. **Deployment**: Estrategias de despliegue
            8. **Monitoreo**: Métricas y alertas
            9. **Troubleshooting**: Problemas comunes
            10. **Contribución**: Guías para desarrolladores

            **Documentación:**
            """
            
            prompt = PromptTemplate(
                input_variables=["code_analysis", "architecture_recommendation", "doc_type"],
                template=prompt_template
            )
            
            if self.llm_model:
                return LLMChain(llm=self.llm_model, prompt=prompt)
            return None
            
        except Exception as e:
            logger.error("Failed to create documentation chain", error=str(e))
            return None
    
    def _create_chat_chain(self) -> Optional[LLMChain]:
        """Crear chain para chat conversacional"""
        try:
            prompt_template = """
            Eres un asistente DevOps experto especializado en análisis de código, arquitecturas de software y documentación técnica.

            Contexto de la conversación:
            {chat_history}

            Pregunta del usuario:
            {user_input}

            Responde de manera técnica pero accesible, proporcionando ejemplos prácticos cuando sea apropiado.

            Respuesta:
            """
            
            prompt = PromptTemplate(
                input_variables=["chat_history", "user_input"],
                template=prompt_template
            )
            
            memory = ConversationBufferMemory(
                memory_key="chat_history",
                return_messages=True
            )
            
            if self.llm_model:
                return LLMChain(
                    llm=self.llm_model, 
                    prompt=prompt,
                    memory=memory
                )
            return None
            
        except Exception as e:
            logger.error("Failed to create chat chain", error=str(e))
            return None
    
    async def analyze_code(self, code_content: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analizar código usando LangChain
        """
        try:
            if not self.chains.get('code_analysis'):
                return self._get_demo_analysis()
            
            with get_openai_callback() as cb:
                result = await self.chains['code_analysis'].arun(
                    code_content=code_content,
                    metadata=str(metadata)
                )
                
                logger.info("Code analysis completed", 
                           tokens_used=cb.total_tokens,
                           cost=cb.total_cost)
                
                return {
                    "analysis": result,
                    "metadata": {
                        "tokens_used": cb.total_tokens,
                        "cost": cb.total_cost,
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
            if not self.chains.get('architecture_recommendation'):
                return self._get_demo_architecture()
            
            with get_openai_callback() as cb:
                result = await self.chains['architecture_recommendation'].arun(
                    code_analysis=code_analysis,
                    reference_architectures="\n".join(reference_architectures),
                    project_requirements=project_requirements
                )
                
                logger.info("Architecture recommendation completed",
                           tokens_used=cb.total_tokens,
                           cost=cb.total_cost)
                
                return {
                    "recommendation": result,
                    "metadata": {
                        "tokens_used": cb.total_tokens,
                        "cost": cb.total_cost,
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
            if not self.chains.get('documentation_generation'):
                return self._get_demo_documentation()
            
            with get_openai_callback() as cb:
                result = await self.chains['documentation_generation'].arun(
                    code_analysis=code_analysis,
                    architecture_recommendation=architecture_recommendation,
                    doc_type=doc_type
                )
                
                logger.info("Documentation generation completed",
                           tokens_used=cb.total_tokens,
                           cost=cb.total_cost)
                
                return {
                    "documentation": result,
                    "metadata": {
                        "tokens_used": cb.total_tokens,
                        "cost": cb.total_cost,
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
            if not self.chains.get('conversational_chat'):
                return self._get_demo_chat_response(user_input)
            
            with get_openai_callback() as cb:
                result = await self.chains['conversational_chat'].arun(
                    user_input=user_input
                )
                
                logger.info("Chat completion completed",
                           tokens_used=cb.total_tokens,
                           cost=cb.total_cost)
                
                return {
                    "response": result,
                    "metadata": {
                        "tokens_used": cb.total_tokens,
                        "cost": cb.total_cost,
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
            ## Análisis de Código (Modo Demo)
            
            ### Tecnologías Identificadas
            - **Framework**: Node.js + Express
            - **Base de datos**: PostgreSQL
            - **Frontend**: React 18
            
            ### Patrón Arquitectónico
            - **Tipo**: API-First Microservice
            - **Estructura**: MVC con separación de responsabilidades
            
            ### Componentes Principales
            - Controllers para manejo de rutas
            - Services para lógica de negocio
            - Models para acceso a datos
            
            ### Recomendaciones
            - Implementar tests unitarios
            - Agregar documentación OpenAPI
            - Configurar monitoreo de performance
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
            ## Recomendación Arquitectónica (Modo Demo)
            
            ### Arquitectura Recomendada
            **Microservicios con API Gateway**
            
            ### Justificación
            - Escalabilidad independiente por servicio
            - Facilita el desarrollo distribuido
            - Permite tecnologías heterogéneas
            
            ### Diagrama Mermaid
            ```mermaid
            graph TB
                A[API Gateway] --> B[Auth Service]
                A --> C[Business Service]
                A --> D[Data Service]
                B --> E[(Auth DB)]
                C --> F[(Business DB)]
                D --> G[(Data DB)]
            ```
            
            ### Estrategia de Migración
            1. Extraer servicios por dominio
            2. Implementar API Gateway
            3. Migrar datos gradualmente
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
            # Proyecto Demo - Documentación Automática
            
            ## Descripción
            Aplicación web moderna con arquitectura de microservicios.
            
            ## Arquitectura
            Sistema distribuido con API Gateway y servicios especializados.
            
            ## Tecnologías
            - **Backend**: Node.js, Express, PostgreSQL
            - **Frontend**: React 18, Material-UI
            - **Infraestructura**: Docker, Kubernetes
            
            ## Instalación
            ```bash
            npm install
            docker-compose up -d
            npm start
            ```
            
            ## API Endpoints
            - `GET /health` - Health check
            - `POST /api/auth` - Autenticación
            - `GET /api/data` - Obtener datos
            
            ## Deployment
            Usar Docker Compose para desarrollo local.
            Kubernetes para producción.
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
            Hola! Soy tu asistente DevOps con IA (modo demo).
            
            Has preguntado: "{user_input}"
            
            Puedo ayudarte con:
            - Análisis de código y arquitecturas
            - Generación de documentación técnica
            - Recomendaciones de mejores prácticas
            - Estrategias de deployment y CI/CD
            
            Para funcionalidad completa, configura tu API key de OpenAI.
            """,
            "metadata": {
                "tokens_used": 0,
                "cost": 0.0,
                "model": "demo-mode"
            }
        }

# Instancia global del servicio
langchain_service = LangChainService()
