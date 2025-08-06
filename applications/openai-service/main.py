# =============================================================================
# IA-OPS OPENAI SERVICE - SERVIDOR PRINCIPAL
# =============================================================================
# Descripción: Servicio de IA con OpenAI para IA-Ops Platform
# Puerto: 8000
# Funcionalidades: Chat completions, embeddings, health checks

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import os
import logging
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel
import openai
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# =============================================================================
# CONFIGURACIÓN
# =============================================================================

app = FastAPI(
    title="IA-Ops OpenAI Service",
    description="Servicio de inteligencia artificial para IA-Ops Platform",
    version="1.0.8",
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
