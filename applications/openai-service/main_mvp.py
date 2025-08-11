# =============================================================================
# IA-OPS OPENAI SERVICE - MVP SIMPLE PARA DEMO
# =============================================================================
# Versión simplificada para demo en 8 horas

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn
import os
import logging
from datetime import datetime
from typing import Dict, Any, Optional
import openai
from dotenv import load_dotenv
import json

# Cargar variables de entorno
load_dotenv()

# =============================================================================
# CONFIGURACIÓN
# =============================================================================

app = FastAPI(
    title="IA-Ops OpenAI Service MVP",
    description="Servicio MVP de IA para demo en 8 horas",
    version="1.0.0-mvp",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configurar OpenAI
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
DEMO_MODE = os.getenv("DEMO_MODE", "true").lower() == "true"

if OPENAI_API_KEY and not DEMO_MODE:
    openai.api_key = OPENAI_API_KEY

# =============================================================================
# MODELOS DE DATOS
# =============================================================================

class RepositoryAnalysisRequest(BaseModel):
    repository_url: str = Field(..., description="URL del repositorio a analizar")
    branch: Optional[str] = Field(default="main", description="Rama a analizar")
    analysis_depth: Optional[str] = Field(default="basic", description="Profundidad del análisis")

class HealthResponse(BaseModel):
    status: str
    timestamp: str
    service: str
    version: str

# =============================================================================
# ENDPOINTS
# =============================================================================

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now().isoformat(),
        service="IA-Ops OpenAI Service MVP",
        version="1.0.0-mvp"
    )

@app.post("/analyze-repository")
async def analyze_repository_mvp(request: RepositoryAnalysisRequest):
    """
    Análisis MVP de repositorio - VERSIÓN SIMPLE PARA DEMO
    """
    try:
        logger.info(f"MVP Analysis for: {request.repository_url}")
        
        # Datos demo específicos para poc-billpay-back (REAL)
        if "poc-billpay-back" in request.repository_url:
            analysis_result = {
                "success": True,
                "repository": "poc-billpay-back",
                "analysis": {
                    "technologies": {
                        "primary_language": "Java",
                        "framework": "Spring Boot 3.4.4",
                        "runtime": "Java 17",
                        "database": "PostgreSQL (inferred)",
                        "build_tool": "Gradle",
                        "dependencies": [
                            "spring-boot-starter-web",
                            "spring-boot-starter-data-jpa", 
                            "spring-boot-starter-security",
                            "spring-boot-starter-validation",
                            "postgresql",
                            "spring-boot-starter-test"
                        ]
                    },
                    "architecture": {
                        "type": "Spring Boot Microservice",
                        "pattern": "Layered Architecture with REST API",
                        "description": "Microservicio Spring Boot para sistema de pagos con arquitectura en capas y API REST"
                    },
                    "components": {
                        "apis": [
                            "/api/v1/payments",
                            "/api/v1/users", 
                            "/api/v1/transactions",
                            "/api/v1/auth",
                            "/health"
                        ],
                        "services": [
                            "PaymentService",
                            "UserService", 
                            "TransactionService",
                            "AuthenticationService",
                            "NotificationService"
                        ],
                        "databases": ["PostgreSQL (primary)", "Redis (cache/sessions)"],
                        "external_services": [
                            "Payment Gateway API",
                            "Email Service",
                            "SMS Notification Service"
                        ]
                    },
                    "recommendations": {
                        "deployment": "Blue-Green Deployment con Spring Boot Actuator - Zero downtime crítico para transacciones",
                        "scaling": "Horizontal scaling con Spring Cloud LoadBalancer, auto-scaling basado en CPU >70%",
                        "monitoring": "Payment success rate >99.9%, API response time <300ms, JVM metrics, Error rate <0.1%",
                        "security": "Spring Security con JWT, API rate limiting, Input validation, HTTPS, SQL injection protection"
                    },
                    "documentation": {
                        "quality": 4,
                        "existing": [
                            "catalog-info.yaml (Backstage)",
                            "README.md",
                            "mkdocs.yml (TechDocs)",
                            "Dockerfile"
                        ],
                        "missing": [
                            "Swagger/OpenAPI 3.0 specification",
                            "Architecture diagrams",
                            "Database schema documentation", 
                            "API testing examples"
                        ],
                        "suggestions": [
                            "Implementar SpringDoc OpenAPI para documentación automática",
                            "Crear diagramas de arquitectura con Mermaid.js",
                            "Documentar esquema de base de datos con JPA entities",
                            "Añadir ejemplos de uso con curl/Postman",
                            "Configurar Spring Boot Actuator para métricas"
                        ]
                    },
                    "spring_boot_features": {
                        "actuator": "Recommended for health checks and metrics",
                        "profiles": "Use for different environments (dev, test, prod)",
                        "configuration": "Externalize configuration with application.yml",
                        "testing": "Use @SpringBootTest for integration tests"
                    },
                    "metrics_to_monitor": {
                        "business": [
                            "payment_success_rate",
                            "transaction_volume",
                            "average_transaction_amount", 
                            "failed_payment_reasons",
                            "user_registration_rate"
                        ],
                        "technical": [
                            "jvm_memory_usage",
                            "jvm_gc_time",
                            "http_request_duration_p95",
                            "database_connection_pool_usage",
                            "error_rate_by_endpoint",
                            "spring_boot_actuator_health"
                        ]
                    }
                },
                "timestamp": datetime.now().isoformat(),
                "mode": "demo_mvp_real_repo"
            }
        else:
            # Análisis genérico para otros repositorios
            repo_name = request.repository_url.split("/")[-1] if "/" in request.repository_url else request.repository_url
            analysis_result = {
                "success": True,
                "repository": repo_name,
                "analysis": {
                    "technologies": {
                        "primary_language": "To be analyzed",
                        "framework": "To be analyzed",
                        "runtime": "To be analyzed", 
                        "database": "To be analyzed",
                        "dependencies": []
                    },
                    "architecture": {
                        "type": "Web Application",
                        "pattern": "Standard Application Pattern",
                        "description": f"Análisis básico para {repo_name} - requiere datos adicionales para análisis detallado"
                    },
                    "components": {
                        "apis": ["To be analyzed"],
                        "services": ["To be analyzed"],
                        "databases": ["To be analyzed"],
                        "external_services": ["To be analyzed"]
                    },
                    "recommendations": {
                        "deployment": "Standard CI/CD deployment",
                        "scaling": "Monitor usage patterns and scale accordingly",
                        "monitoring": "Basic application and infrastructure metrics",
                        "security": "Implement standard security practices"
                    },
                    "documentation": {
                        "quality": 2,
                        "missing": ["Detailed repository analysis needed"],
                        "suggestions": ["Provide repository access for detailed analysis"]
                    }
                },
                "timestamp": datetime.now().isoformat(),
                "mode": "demo_mvp"
            }
        
        return {
            "success": True,
            "message": "Repository analysis completed (MVP Demo)",
            "repository_url": request.repository_url,
            "branch": request.branch,
            "analysis_id": f"mvp-analysis-{datetime.now().timestamp()}",
            "status": "completed",
            "result": analysis_result,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"MVP Analysis error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "IA-Ops OpenAI Service MVP",
        "version": "1.0.0-mvp",
        "status": "running",
        "endpoints": [
            "/health",
            "/analyze-repository",
            "/docs"
        ],
        "demo_mode": DEMO_MODE,
        "timestamp": datetime.now().isoformat()
    }

# =============================================================================
# STARTUP
# =============================================================================

@app.on_event("startup")
async def startup_event():
    """Inicialización del servicio MVP"""
    logger.info("🚀 Starting IA-Ops OpenAI Service MVP")
    logger.info(f"📊 Model: {OPENAI_MODEL}")
    logger.info(f"🔧 Demo Mode: {DEMO_MODE}")
    logger.info("🎯 MVP Mode: Ready for 8-hour demo")

if __name__ == "__main__":
    uvicorn.run(
        "main_mvp:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
