# =============================================================================
# IA-OPS OPENAI SERVICE - SERVIDOR PRINCIPAL CON LANGCHAIN
# =============================================================================
# Descripción: Servicio de IA con OpenAI y LangChain para IA-Ops Platform
# Puerto: 8000
# Funcionalidades: Chat completions, análisis de código, generación de docs

from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import os
import logging
from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
import openai
from dotenv import load_dotenv
import asyncio
import json

# Importar servicio LangChain simplificado
from langchain_service_simple import simple_langchain_service

# Cargar variables de entorno
load_dotenv()

# =============================================================================
# CONFIGURACIÓN
# =============================================================================

app = FastAPI(
    title="IA-Ops OpenAI Service with LangChain",
    description="Servicio de inteligencia artificial con LangChain para análisis de código y documentación",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios específicos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configurar logging
logging.basicConfig(
    level=getattr(logging, os.getenv('LOG_LEVEL', 'INFO').upper()),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# =============================================================================
# MODELOS DE DATOS
# =============================================================================

class ChatMessage(BaseModel):
    role: str = Field(..., description="Rol del mensaje: user, assistant, system")
    content: str = Field(..., description="Contenido del mensaje")

class ChatCompletionRequest(BaseModel):
    messages: List[ChatMessage] = Field(..., description="Lista de mensajes del chat")
    model: Optional[str] = Field(default="gpt-4o-mini", description="Modelo a utilizar")
    max_tokens: Optional[int] = Field(default=150, description="Máximo número de tokens")
    temperature: Optional[float] = Field(default=0.7, description="Temperatura para la generación")

class CompletionRequest(BaseModel):
    prompt: str = Field(..., description="Prompt para completion")
    model: Optional[str] = Field(default="gpt-4o-mini", description="Modelo a utilizar")
    max_tokens: Optional[int] = Field(default=150, description="Máximo número de tokens")
    temperature: Optional[float] = Field(default=0.7, description="Temperatura para la generación")

class CodeAnalysisRequest(BaseModel):
    code_content: str = Field(..., description="Contenido del código a analizar")
    language: Optional[str] = Field(default="javascript", description="Lenguaje de programación")
    project_type: Optional[str] = Field(default="web-application", description="Tipo de proyecto")
    metadata: Optional[Dict[str, Any]] = Field(default={}, description="Metadatos del proyecto")

class ArchitectureRecommendationRequest(BaseModel):
    code_analysis: str = Field(..., description="Resultado del análisis de código")
    reference_architectures: List[str] = Field(default=[], description="Arquitecturas de referencia")
    project_requirements: str = Field(default="", description="Requisitos del proyecto")

class DocumentationGenerationRequest(BaseModel):
    code_analysis: str = Field(..., description="Análisis de código")
    architecture_recommendation: str = Field(..., description="Recomendación arquitectónica")
    doc_type: Optional[str] = Field(default="README", description="Tipo de documentación")
    project_name: Optional[str] = Field(default="Mi Proyecto", description="Nombre del proyecto")

# =============================================================================
# CONFIGURACIÓN OPENAI
# =============================================================================

# Configurar OpenAI
openai.api_key = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
OPENAI_MAX_TOKENS = int(os.getenv("OPENAI_MAX_TOKENS", "150"))
OPENAI_TEMPERATURE = float(os.getenv("OPENAI_TEMPERATURE", "0.7"))

# Verificar configuración
if not openai.api_key:
    logger.warning("OpenAI API key not configured. Running in demo mode.")
    DEMO_MODE = True
else:
    DEMO_MODE = False
    logger.info(f"OpenAI configured with model: {OPENAI_MODEL}")

# =============================================================================
# ENDPOINTS BÁSICOS
# =============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "2.0.0",
        "langchain_enabled": True,
        "demo_mode": DEMO_MODE,
        "model": OPENAI_MODEL
    }

@app.post("/chat/completions")
async def chat_completions(request: ChatCompletionRequest):
    """Chat completions endpoint (compatible con OpenAI API)"""
    try:
        # Usar LangChain para chat
        user_message = request.messages[-1].content if request.messages else ""
        
        result = await simple_langchain_service.chat_completion(user_message)
        
        return {
            "id": f"chatcmpl-{datetime.now().timestamp()}",
            "object": "chat.completion",
            "created": int(datetime.now().timestamp()),
            "model": request.model,
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": result["response"]
                },
                "finish_reason": "stop"
            }],
            "usage": {
                "prompt_tokens": result["metadata"].get("tokens_used", 0),
                "completion_tokens": result["metadata"].get("tokens_used", 0),
                "total_tokens": result["metadata"].get("tokens_used", 0)
            }
        }
        
    except Exception as e:
        logger.error(f"Chat completion error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/completions")
async def completions(request: CompletionRequest):
    """Simple completions endpoint"""
    try:
        result = await simple_langchain_service.chat_completion(request.prompt)
        
        return {
            "id": f"cmpl-{datetime.now().timestamp()}",
            "object": "text_completion",
            "created": int(datetime.now().timestamp()),
            "model": request.model,
            "choices": [{
                "text": result["response"],
                "index": 0,
                "finish_reason": "stop"
            }],
            "usage": {
                "prompt_tokens": result["metadata"].get("tokens_used", 0),
                "completion_tokens": result["metadata"].get("tokens_used", 0),
                "total_tokens": result["metadata"].get("tokens_used", 0)
            }
        }
        
    except Exception as e:
        logger.error(f"Completion error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# =============================================================================
# ENDPOINTS LANGCHAIN - ASISTENTE DEVOPS IA
# =============================================================================

@app.post("/analyze-code")
async def analyze_code(request: CodeAnalysisRequest):
    """
    Analizar código usando LangChain
    Endpoint principal del Asistente DevOps IA
    """
    try:
        logger.info(f"Starting code analysis for {request.language} project")
        
        # Usar LangChain para análisis
        result = await simple_langchain_service.analyze_code(
            code_content=request.code_content,
            metadata={
                "language": request.language,
                "project_type": request.project_type,
                **request.metadata
            }
        )
        
        return {
            "success": True,
            "analysis": result["analysis"],
            "metadata": result["metadata"],
            "timestamp": datetime.now().isoformat(),
            "service": "langchain-analysis"
        }
        
    except Exception as e:
        logger.error(f"Code analysis error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@app.post("/recommend-architecture")
async def recommend_architecture(request: ArchitectureRecommendationRequest):
    """
    Recomendar arquitectura basada en análisis de código
    """
    try:
        logger.info("Starting architecture recommendation")
        
        result = await simple_langchain_service.recommend_architecture(
            code_analysis=request.code_analysis,
            reference_architectures=request.reference_architectures,
            project_requirements=request.project_requirements
        )
        
        return {
            "success": True,
            "recommendation": result["recommendation"],
            "metadata": result["metadata"],
            "timestamp": datetime.now().isoformat(),
            "service": "langchain-architecture"
        }
        
    except Exception as e:
        logger.error(f"Architecture recommendation error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Recommendation failed: {str(e)}")

@app.post("/generate-documentation")
async def generate_documentation(request: DocumentationGenerationRequest):
    """
    Generar documentación automática usando LangChain
    """
    try:
        logger.info(f"Starting documentation generation for {request.doc_type}")
        
        result = await simple_langchain_service.generate_documentation(
            code_analysis=request.code_analysis,
            architecture_recommendation=request.architecture_recommendation,
            doc_type=request.doc_type
        )
        
        return {
            "success": True,
            "documentation": result["documentation"],
            "doc_type": request.doc_type,
            "project_name": request.project_name,
            "metadata": result["metadata"],
            "timestamp": datetime.now().isoformat(),
            "service": "langchain-documentation"
        }
        
    except Exception as e:
        logger.error(f"Documentation generation error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Documentation failed: {str(e)}")

@app.get("/langchain/status")
async def langchain_status():
    """
    Estado del servicio LangChain
    """
    try:
        return {
            "langchain_enabled": True,
            "service_type": "simple_langchain_service",
            "model": OPENAI_MODEL,
            "demo_mode": DEMO_MODE,
            "api_key_configured": bool(openai.api_key),
            "available_endpoints": [
                "/analyze-code",
                "/recommend-architecture", 
                "/generate-documentation",
                "/devops-assistant/full-analysis"
            ],
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"LangChain status error: {str(e)}")
        return {
            "langchain_enabled": False,
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }

# =============================================================================
# ENDPOINT DE PIPELINE COMPLETO
# =============================================================================

@app.post("/devops-assistant/full-analysis")
async def full_devops_analysis(request: CodeAnalysisRequest):
    """
    Pipeline completo del Asistente DevOps IA:
    1. Análisis de código
    2. Recomendación arquitectónica  
    3. Generación de documentación
    """
    try:
        logger.info("Starting full DevOps analysis pipeline")
        
        # Paso 1: Análisis de código
        logger.info("Step 1: Code analysis")
        code_result = await simple_langchain_service.analyze_code(
            code_content=request.code_content,
            metadata={
                "language": request.language,
                "project_type": request.project_type,
                **request.metadata
            }
        )
        
        # Paso 2: Recomendación arquitectónica
        logger.info("Step 2: Architecture recommendation")
        arch_result = await simple_langchain_service.recommend_architecture(
            code_analysis=code_result["analysis"],
            reference_architectures=[
                "Microservices with API Gateway",
                "Monolithic Architecture", 
                "Serverless Architecture",
                "Event-Driven Architecture"
            ],
            project_requirements=f"Project type: {request.project_type}, Language: {request.language}"
        )
        
        # Paso 3: Generación de documentación
        logger.info("Step 3: Documentation generation")
        doc_result = await simple_langchain_service.generate_documentation(
            code_analysis=code_result["analysis"],
            architecture_recommendation=arch_result["recommendation"],
            doc_type="README"
        )
        
        return {
            "success": True,
            "pipeline": "full-devops-analysis",
            "results": {
                "code_analysis": {
                    "content": code_result["analysis"],
                    "metadata": code_result["metadata"]
                },
                "architecture_recommendation": {
                    "content": arch_result["recommendation"],
                    "metadata": arch_result["metadata"]
                },
                "documentation": {
                    "content": doc_result["documentation"],
                    "metadata": doc_result["metadata"]
                }
            },
            "total_tokens": (
                code_result["metadata"].get("tokens_used", 0) +
                arch_result["metadata"].get("tokens_used", 0) +
                doc_result["metadata"].get("tokens_used", 0)
            ),
            "timestamp": datetime.now().isoformat(),
            "processing_time": "completed",
            "service": "langchain-full-pipeline"
        }
        
    except Exception as e:
        logger.error(f"Full analysis pipeline error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Full analysis failed: {str(e)}")

# =============================================================================
# INICIALIZACIÓN
# =============================================================================

@app.on_event("startup")
async def startup_event():
    """Inicialización del servicio"""
    logger.info("🚀 Starting IA-Ops OpenAI Service with LangChain")
    logger.info(f"📊 Model: {OPENAI_MODEL}")
    logger.info(f"🔧 Demo Mode: {DEMO_MODE}")
    logger.info("🔗 LangChain Service: SimpleLangChainService initialized")

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", "8000")),
        reload=True,
        log_level="info"
    )

# =============================================================================
# MODELOS DE DATOS
# =============================================================================

class ChatMessage(BaseModel):
    role: str = Field(..., description="Rol del mensaje: user, assistant, system")
    content: str = Field(..., description="Contenido del mensaje")

class ChatCompletionRequest(BaseModel):
    messages: List[ChatMessage] = Field(..., description="Lista de mensajes del chat")
    model: Optional[str] = Field(default="gpt-4o-mini", description="Modelo a utilizar")
    max_tokens: Optional[int] = Field(default=150, description="Máximo número de tokens")
    temperature: Optional[float] = Field(default=0.7, description="Temperatura para la generación")

class CompletionRequest(BaseModel):
    prompt: str = Field(..., description="Prompt para completion")
    model: Optional[str] = Field(default="gpt-4o-mini", description="Modelo a utilizar")
    max_tokens: Optional[int] = Field(default=150, description="Máximo número de tokens")
    temperature: Optional[float] = Field(default=0.7, description="Temperatura para la generación")

class CodeAnalysisRequest(BaseModel):
    code_content: str = Field(..., description="Contenido del código a analizar")
    language: Optional[str] = Field(default="javascript", description="Lenguaje de programación")
    project_type: Optional[str] = Field(default="web-application", description="Tipo de proyecto")
    metadata: Optional[Dict[str, Any]] = Field(default={}, description="Metadatos del proyecto")
    additional_files: Optional[Dict[str, str]] = Field(default={}, description="Archivos adicionales")

class ArchitectureRecommendationRequest(BaseModel):
    code_analysis: str = Field(..., description="Resultado del análisis de código")
    reference_architectures: List[str] = Field(default=[], description="Arquitecturas de referencia")
    project_requirements: Dict[str, Any] = Field(default={}, description="Requisitos del proyecto")

class DocumentationGenerationRequest(BaseModel):
    code_analysis: str = Field(..., description="Análisis de código")
    architecture_recommendation: str = Field(..., description="Recomendación arquitectónica")
    doc_type: Optional[str] = Field(default="README", description="Tipo de documentación")
    project_name: Optional[str] = Field(default="Mi Proyecto", description="Nombre del proyecto")
    target_audience: Optional[str] = Field(default="developers", description="Audiencia objetivo")

class RepositoryAnalysisRequest(BaseModel):
    repository_url: str = Field(..., description="URL del repositorio a analizar")
    branch: Optional[str] = Field(default="main", description="Rama a analizar")
    analysis_depth: Optional[str] = Field(default="full", description="Profundidad del análisis")

# =============================================================================
# CONFIGURACIÓN OPENAI
# =============================================================================

# Configurar OpenAI
openai.api_key = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
OPENAI_MAX_TOKENS = int(os.getenv("OPENAI_MAX_TOKENS", "150"))
OPENAI_TEMPERATURE = float(os.getenv("OPENAI_TEMPERATURE", "0.7"))

# Verificar configuración
if not openai.api_key:
    logger.warning("OpenAI API key not configured. Running in demo mode.")
    DEMO_MODE = True
else:
    DEMO_MODE = False
    logger.info(f"OpenAI configured with model: {OPENAI_MODEL}")

# =============================================================================
# ENDPOINTS EXISTENTES (COMPATIBILIDAD)
# =============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "2.0.0",
        "langchain_enabled": True,
        "demo_mode": DEMO_MODE,
        "model": OPENAI_MODEL
    }

@app.post("/chat/completions")
async def chat_completions(request: ChatCompletionRequest):
    """Chat completions endpoint (compatible con OpenAI API)"""
    try:
        # Usar LangChain para chat
        user_message = request.messages[-1].content if request.messages else ""
        
        result = await langchain_service.chat_completion(user_message)
        
        return {
            "id": f"chatcmpl-{datetime.now().timestamp()}",
            "object": "chat.completion",
            "created": int(datetime.now().timestamp()),
            "model": request.model,
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": result["response"]
                },
                "finish_reason": "stop"
            }],
            "usage": {
                "prompt_tokens": result["metadata"].get("tokens_used", 0),
                "completion_tokens": result["metadata"].get("tokens_used", 0),
                "total_tokens": result["metadata"].get("tokens_used", 0)
            }
        }
        
    except Exception as e:
        logger.error(f"Chat completion error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/completions")
async def completions(request: CompletionRequest):
    """Simple completions endpoint"""
    try:
        result = await langchain_service.chat_completion(request.prompt)
        
        return {
            "id": f"cmpl-{datetime.now().timestamp()}",
            "object": "text_completion",
            "created": int(datetime.now().timestamp()),
            "model": request.model,
            "choices": [{
                "text": result["response"],
                "index": 0,
                "finish_reason": "stop"
            }],
            "usage": {
                "prompt_tokens": result["metadata"].get("tokens_used", 0),
                "completion_tokens": result["metadata"].get("tokens_used", 0),
                "total_tokens": result["metadata"].get("tokens_used", 0)
            }
        }
        
    except Exception as e:
        logger.error(f"Completion error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# =============================================================================
# NUEVOS ENDPOINTS LANGCHAIN - ASISTENTE DEVOPS IA
# =============================================================================

@app.post("/analyze-code")
async def analyze_code(request: CodeAnalysisRequest):
    """
    Analizar código usando LangChain
    Endpoint principal del Asistente DevOps IA
    """
    try:
        logger.info(f"Starting code analysis for {request.language} project")
        
        # Usar LangChain para análisis
        result = await langchain_service.analyze_code(
            code_content=request.code_content,
            metadata={
                "language": request.language,
                "project_type": request.project_type,
                **request.metadata
            }
        )
        
        return {
            "success": True,
            "analysis": result["analysis"],
            "metadata": result["metadata"],
            "timestamp": datetime.now().isoformat(),
            "service": "langchain-analysis"
        }
        
    except Exception as e:
        logger.error(f"Code analysis error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@app.post("/recommend-architecture")
async def recommend_architecture(request: ArchitectureRecommendationRequest):
    """
    Recomendar arquitectura basada en análisis de código
    """
    try:
        logger.info("Starting architecture recommendation")
        
        result = await langchain_service.recommend_architecture(
            code_analysis=request.code_analysis,
            reference_architectures=request.reference_architectures,
            project_requirements=json.dumps(request.project_requirements)
        )
        
        return {
            "success": True,
            "recommendation": result["recommendation"],
            "metadata": result["metadata"],
            "timestamp": datetime.now().isoformat(),
            "service": "langchain-architecture"
        }
        
    except Exception as e:
        logger.error(f"Architecture recommendation error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Recommendation failed: {str(e)}")

@app.post("/generate-documentation")
async def generate_documentation(request: DocumentationGenerationRequest):
    """
    Generar documentación automática usando LangChain
    """
    try:
        logger.info(f"Starting documentation generation for {request.doc_type}")
        
        result = await langchain_service.generate_documentation(
            code_analysis=request.code_analysis,
            architecture_recommendation=request.architecture_recommendation,
            doc_type=request.doc_type
        )
        
        return {
            "success": True,
            "documentation": result["documentation"],
            "doc_type": request.doc_type,
            "project_name": request.project_name,
            "metadata": result["metadata"],
            "timestamp": datetime.now().isoformat(),
            "service": "langchain-documentation"
        }
        
    except Exception as e:
        logger.error(f"Documentation generation error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Documentation failed: {str(e)}")

@app.post("/analyze-repository")
async def analyze_repository(request: RepositoryAnalysisRequest, background_tasks: BackgroundTasks):
    """
    Analizar repositorio completo - VERSIÓN MVP SIMPLE
    """
    try:
        logger.info(f"Starting simple repository analysis for {request.repository_url}")
        
        # Para MVP: usar datos demo de poc-billpay-back
        if "poc-billpay-back" in request.repository_url:
            # Datos demo del repositorio BillPay Backend
            repo_data = {
                "name": "poc-billpay-back",
                "package_json": {
                    "name": "poc-billpay-backend",
                    "version": "1.0.0",
                    "description": "BillPay Backend Service - Payment Processing API",
                    "main": "server.js",
                    "scripts": {
                        "start": "node server.js",
                        "dev": "nodemon server.js",
                        "test": "jest"
                    },
                    "dependencies": {
                        "express": "^4.18.0",
                        "pg": "^8.8.0",
                        "bcryptjs": "^2.4.3",
                        "jsonwebtoken": "^8.5.1",
                        "cors": "^2.8.5",
                        "helmet": "^6.0.0",
                        "express-rate-limit": "^6.6.0",
                        "joi": "^17.7.0",
                        "dotenv": "^16.0.3"
                    },
                    "devDependencies": {
                        "nodemon": "^2.0.20",
                        "jest": "^29.3.1",
                        "supertest": "^6.3.3"
                    }
                },
                "readme": """# BillPay Backend Service

Sistema de pagos backend con Node.js y Express.

## Características
- API REST para procesamiento de pagos
- Autenticación JWT
- Base de datos PostgreSQL
- Rate limiting y seguridad
- Tests automatizados

## Endpoints
- POST /api/auth/login
- POST /api/auth/register
- GET /api/payments
- POST /api/payments/process
- GET /api/users/profile

## Tecnologías
- Node.js + Express
- PostgreSQL
- JWT Authentication
- Bcrypt para passwords
- Helmet para seguridad"""
            }
        else:
            # Para otros repos, datos básicos
            repo_data = {
                "name": request.repository_url.split("/")[-1],
                "package_json": {},
                "readme": "Repository analysis - basic data"
            }
        
        # Importar y usar analizador simple
        from analyze_simple import simple_analyzer
        
        # Ejecutar análisis
        analysis_result = await simple_analyzer.analyze_repository_simple(repo_data)
        
        return {
            "success": True,
            "message": "Repository analysis completed",
            "repository_url": request.repository_url,
            "branch": request.branch,
            "analysis_id": f"analysis-{datetime.now().timestamp()}",
            "status": "completed",
            "result": analysis_result,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Repository analysis error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Repository analysis failed: {str(e)}")

@app.get("/langchain/status")
async def langchain_status():
    """
    Estado del servicio LangChain
    """
    try:
        return {
            "langchain_enabled": True,
            "chains_available": list(langchain_service.chains.keys()) if langchain_service.chains else [],
            "model": OPENAI_MODEL,
            "demo_mode": DEMO_MODE,
            "api_key_configured": bool(openai.api_key),
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"LangChain status error: {str(e)}")
        return {
            "langchain_enabled": False,
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }

# =============================================================================
# ENDPOINT DE PIPELINE COMPLETO
# =============================================================================

@app.post("/devops-assistant/full-analysis")
async def full_devops_analysis(request: CodeAnalysisRequest):
    """
    Pipeline completo del Asistente DevOps IA:
    1. Análisis de código
    2. Recomendación arquitectónica  
    3. Generación de documentación
    """
    try:
        logger.info("Starting full DevOps analysis pipeline")
        
        # Paso 1: Análisis de código
        logger.info("Step 1: Code analysis")
        code_result = await langchain_service.analyze_code(
            code_content=request.code_content,
            metadata={
                "language": request.language,
                "project_type": request.project_type,
                **request.metadata
            }
        )
        
        # Paso 2: Recomendación arquitectónica
        logger.info("Step 2: Architecture recommendation")
        arch_result = await langchain_service.recommend_architecture(
            code_analysis=code_result["analysis"],
            reference_architectures=[
                "Microservices with API Gateway",
                "Monolithic Architecture", 
                "Serverless Architecture",
                "Event-Driven Architecture"
            ],
            project_requirements=json.dumps(request.metadata)
        )
        
        # Paso 3: Generación de documentación
        logger.info("Step 3: Documentation generation")
        doc_result = await langchain_service.generate_documentation(
            code_analysis=code_result["analysis"],
            architecture_recommendation=arch_result["recommendation"],
            doc_type="README"
        )
        
        return {
            "success": True,
            "pipeline": "full-devops-analysis",
            "results": {
                "code_analysis": {
                    "content": code_result["analysis"],
                    "metadata": code_result["metadata"]
                },
                "architecture_recommendation": {
                    "content": arch_result["recommendation"],
                    "metadata": arch_result["metadata"]
                },
                "documentation": {
                    "content": doc_result["documentation"],
                    "metadata": doc_result["metadata"]
                }
            },
            "total_tokens": (
                code_result["metadata"].get("tokens_used", 0) +
                arch_result["metadata"].get("tokens_used", 0) +
                doc_result["metadata"].get("tokens_used", 0)
            ),
            "timestamp": datetime.now().isoformat(),
            "processing_time": "completed",
            "service": "langchain-full-pipeline"
        }
        
    except Exception as e:
        logger.error(f"Full analysis pipeline error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Full analysis failed: {str(e)}")

# =============================================================================
# INICIALIZACIÓN
# =============================================================================

@app.on_event("startup")
async def startup_event():
    """Inicialización del servicio"""
    logger.info("🚀 Starting IA-Ops OpenAI Service with LangChain")
    logger.info(f"📊 Model: {OPENAI_MODEL}")
    logger.info(f"🔧 Demo Mode: {DEMO_MODE}")
    # logger.info(f"🔗 LangChain Chains: {list(langchain_service.chains.keys()) if langchain_service.chains else 'None'}")
    logger.info("🔗 LangChain Service: Ready for MVP demo")

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", "8000")),
        reload=True,
        log_level="info"
    )

# Configurar OpenAI
openai.api_key = os.getenv('OPENAI_API_KEY')
if not openai.api_key:
    logger.warning("OPENAI_API_KEY no configurada, usando modo demo")

# =============================================================================
# MODELOS PYDANTIC
# =============================================================================

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatCompletionRequest(BaseModel):
    messages: List[ChatMessage]
    model: Optional[str] = None
    max_tokens: Optional[int] = None
    temperature: Optional[float] = None

class ChatCompletionResponse(BaseModel):
    id: str
    object: str
    created: int
    model: str
    choices: List[dict]
    usage: dict

# =============================================================================
# ENDPOINTS
# =============================================================================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "openai-service",
        "version": "1.0.8",
        "timestamp": datetime.utcnow().isoformat(),
        "openai_configured": bool(openai.api_key),
        "demo_mode": os.getenv('OPENAI_DEMO_MODE', 'false').lower() == 'true'
    }

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "IA-Ops OpenAI Service",
        "version": "1.0.8",
        "docs": "/docs"
    }

@app.post("/chat/completions")
async def chat_completions(request: ChatCompletionRequest):
    """
    Endpoint compatible con OpenAI Chat Completions API
    """
    try:
        # Modo demo si no hay API key
        if not openai.api_key or os.getenv('OPENAI_DEMO_MODE', 'false').lower() == 'true':
            logger.info("Usando modo demo para chat completions")
            return {
                "id": "chatcmpl-demo-123",
                "object": "chat.completion",
                "created": int(datetime.utcnow().timestamp()),
                "model": request.model or os.getenv('OPENAI_MODEL', 'gpt-4o-mini'),
                "choices": [{
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": f"[DEMO MODE] Respuesta simulada para: {request.messages[-1].content if request.messages else 'mensaje vacío'}"
                    },
                    "finish_reason": "stop"
                }],
                "usage": {
                    "prompt_tokens": 10,
                    "completion_tokens": 20,
                    "total_tokens": 30
                }
            }

        # Usar OpenAI real
        client = openai.OpenAI(api_key=openai.api_key)
        
        response = client.chat.completions.create(
            model=request.model or os.getenv('OPENAI_MODEL', 'gpt-4o-mini'),
            messages=[{"role": msg.role, "content": msg.content} for msg in request.messages],
            max_tokens=request.max_tokens or int(os.getenv('OPENAI_MAX_TOKENS', '2000')),
            temperature=request.temperature or float(os.getenv('OPENAI_TEMPERATURE', '0.7'))
        )
        
        return response.model_dump()
        
    except Exception as e:
        logger.error(f"Error en chat completions: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error procesando solicitud: {str(e)}")

@app.get("/models")
async def list_models():
    """Listar modelos disponibles"""
    return {
        "object": "list",
        "data": [
            {
                "id": "gpt-4o-mini",
                "object": "model",
                "created": int(datetime.utcnow().timestamp()),
                "owned_by": "openai"
            },
            {
                "id": "gpt-4",
                "object": "model", 
                "created": int(datetime.utcnow().timestamp()),
                "owned_by": "openai"
            }
        ]
    }

# =============================================================================
# MANEJO DE ERRORES
# =============================================================================

@app.exception_handler(404)
async def not_found_handler(request, exc):
    return JSONResponse(
        status_code=404,
        content={
            "error": "Endpoint no encontrado",
            "path": str(request.url.path),
            "method": request.method
        }
    )

@app.exception_handler(500)
async def internal_error_handler(request, exc):
    logger.error(f"Error interno: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Error interno del servidor",
            "timestamp": datetime.utcnow().isoformat()
        }
    )

# =============================================================================
# STARTUP
# =============================================================================

if __name__ == "__main__":
    port = int(os.getenv('OPENAI_SERVICE_PORT', '8000'))
    host = os.getenv('OPENAI_SERVICE_HOST', '0.0.0.0')
    
    logger.info(f"🤖 Iniciando IA-Ops OpenAI Service en {host}:{port}")
    logger.info(f"📊 Demo Mode: {os.getenv('OPENAI_DEMO_MODE', 'false')}")
    logger.info(f"🔑 OpenAI API Key configurada: {bool(openai.api_key)}")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=os.getenv('DEBUG_MODE', 'false').lower() == 'true'
    )
