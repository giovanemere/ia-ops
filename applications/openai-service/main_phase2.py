# =============================================================================
# IA-OPS OPENAI SERVICE - FASE 2 EXPANDIDO
# =============================================================================
# Versión expandida para manejar múltiples repositorios y tipos de análisis

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn
import os
import logging
from datetime import datetime
from typing import Dict, Any, Optional, List
import openai
from dotenv import load_dotenv
import json

# Cargar variables de entorno
load_dotenv()

# =============================================================================
# CONFIGURACIÓN
# =============================================================================

app = FastAPI(
    title="IA-Ops OpenAI Service - Phase 2",
    description="Servicio expandido de IA para análisis de múltiples repositorios",
    version="2.0.0-phase2",
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
# MODELOS DE DATOS EXPANDIDOS
# =============================================================================

class PackageJson(BaseModel):
    name: str
    version: str
    dependencies: Dict[str, str]
    scripts: Dict[str, str]

class RepositoryData(BaseModel):
    name: str
    description: str
    url: str
    language: str
    package_json: Optional[PackageJson] = None
    readme: Optional[str] = None
    files: Optional[List[str]] = None

class RepositoryAnalysisRequest(BaseModel):
    repository_url: Optional[str] = None
    repository_data: Optional[RepositoryData] = None
    branch: Optional[str] = Field(default="main", description="Rama a analizar")
    analysis_depth: Optional[str] = Field(default="basic", description="Profundidad del análisis")

class TechnologyStack(BaseModel):
    primary_language: str
    framework: str
    runtime: str
    build_tool: str
    dependencies: List[str]

class ArchitectureInfo(BaseModel):
    pattern: str
    type: str
    description: str
    components: List[str]

class APIEndpoint(BaseModel):
    path: str
    method: str
    description: str

class AnalysisResult(BaseModel):
    success: bool
    repository: str
    analysis: Dict[str, Any]
    timestamp: str
    analysis_type: str

class HealthResponse(BaseModel):
    status: str
    timestamp: str
    service: str
    version: str

# =============================================================================
# FUNCIONES DE ANÁLISIS
# =============================================================================

def analyze_react_frontend(repo_data: RepositoryData) -> Dict[str, Any]:
    """Análisis específico para aplicaciones React"""
    
    package_json = repo_data.package_json
    dependencies = package_json.dependencies if package_json else {}
    
    # Identificar tecnologías React
    technologies = {
        "primary_language": repo_data.language,
        "framework": "React",
        "runtime": "Node.js",
        "build_tool": "Create React App",
        "dependencies": []
    }
    
    # Detectar versión de React
    if "react" in dependencies:
        react_version = dependencies["react"].replace("^", "").replace("~", "")
        technologies["framework"] = f"React {react_version}"
    
    # Detectar UI library
    ui_library = "None"
    if "@mui/material" in dependencies:
        ui_library = "Material-UI"
        technologies["dependencies"].append("Material-UI")
    elif "@chakra-ui/react" in dependencies:
        ui_library = "Chakra UI"
        technologies["dependencies"].append("Chakra UI")
    elif "antd" in dependencies:
        ui_library = "Ant Design"
        technologies["dependencies"].append("Ant Design")
    
    # Detectar otras dependencias importantes
    if "typescript" in dependencies:
        technologies["dependencies"].append("TypeScript")
    if "axios" in dependencies:
        technologies["dependencies"].append("Axios")
    if "react-router-dom" in dependencies:
        technologies["dependencies"].append("React Router")
    
    # Arquitectura
    architecture = {
        "pattern": "Single Page Application (SPA)",
        "type": "Frontend Web Application",
        "description": f"React SPA con {ui_library} para interfaz de usuario",
        "components": [
            "React Components",
            "State Management",
            "Routing System",
            "HTTP Client",
            "UI Components"
        ]
    }
    
    # APIs simuladas (en producción se analizaría el código)
    apis = [
        {"path": "/api/payments", "method": "GET", "description": "Obtener lista de pagos"},
        {"path": "/api/users/profile", "method": "GET", "description": "Obtener perfil de usuario"},
        {"path": "/api/payments", "method": "POST", "description": "Crear nuevo pago"},
        {"path": "/api/payments/:id", "method": "PUT", "description": "Actualizar pago"}
    ]
    
    return {
        "technologies": technologies,
        "architecture": architecture,
        "apis": apis,
        "ui_library": ui_library,
        "build_system": "Create React App",
        "deployment_type": "Static Web App"
    }

def analyze_java_backend(repo_data: RepositoryData) -> Dict[str, Any]:
    """Análisis específico para aplicaciones Java/Spring Boot"""
    
    # Datos específicos para poc-billpay-back
    technologies = {
        "primary_language": "Java",
        "framework": "Spring Boot 3.4.4",
        "runtime": "Java 17",
        "build_tool": "Gradle",
        "dependencies": [
            "Spring Web",
            "Spring Data JPA",
            "PostgreSQL Driver",
            "Spring Security",
            "Spring Boot Actuator"
        ]
    }
    
    architecture = {
        "pattern": "Spring Boot Microservice",
        "type": "REST API Backend",
        "description": "Microservicio Spring Boot para sistema de pagos",
        "components": [
            "REST Controllers",
            "Service Layer",
            "Data Access Layer",
            "Security Configuration",
            "Database Integration"
        ]
    }
    
    apis = [
        {"path": "/api/payments", "method": "GET", "description": "Listar pagos"},
        {"path": "/api/payments", "method": "POST", "description": "Crear pago"},
        {"path": "/api/payments/{id}", "method": "GET", "description": "Obtener pago por ID"},
        {"path": "/api/payments/{id}", "method": "PUT", "description": "Actualizar pago"},
        {"path": "/api/users", "method": "GET", "description": "Listar usuarios"},
        {"path": "/actuator/health", "method": "GET", "description": "Health check"}
    ]
    
    return {
        "technologies": technologies,
        "architecture": architecture,
        "apis": apis,
        "database": "PostgreSQL",
        "deployment_type": "Containerized Microservice"
    }

# =============================================================================
# ENDPOINTS
# =============================================================================

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now().isoformat(),
        service="IA-Ops OpenAI Service - Phase 2",
        version="2.0.0-phase2"
    )

@app.post("/analyze-repository")
async def analyze_repository_flexible(request: RepositoryAnalysisRequest):
    """
    Análisis flexible de repositorio - Soporta múltiples formatos de entrada
    """
    try:
        # Determinar fuente de datos
        if request.repository_data:
            repo_data = request.repository_data
            repo_name = repo_data.name
        elif request.repository_url:
            # Extraer nombre del repositorio de la URL
            repo_name = request.repository_url.split("/")[-1].replace(".git", "")
            # Crear datos básicos del repositorio
            repo_data = RepositoryData(
                name=repo_name,
                description=f"Repository {repo_name}",
                url=request.repository_url,
                language="Unknown"
            )
        else:
            raise HTTPException(status_code=400, detail="Se requiere repository_url o repository_data")
        
        logger.info(f"Phase 2 Analysis for: {repo_name}")
        
        # Análisis específico por tipo de aplicación
        if "front" in repo_name.lower() and repo_data.package_json:
            # Frontend React
            analysis_result = analyze_react_frontend(repo_data)
            analysis_type = "React Frontend"
        elif "back" in repo_name.lower() or repo_data.language == "Java":
            # Backend Java
            analysis_result = analyze_java_backend(repo_data)
            analysis_type = "Java Backend"
        else:
            # Análisis genérico
            analysis_result = {
                "technologies": {
                    "primary_language": repo_data.language,
                    "framework": "Unknown",
                    "runtime": "Unknown",
                    "build_tool": "Unknown",
                    "dependencies": []
                },
                "architecture": {
                    "pattern": "Unknown",
                    "type": "Unknown",
                    "description": "Análisis genérico requerido",
                    "components": []
                },
                "apis": []
            }
            analysis_type = "Generic"
        
        return {
            "success": True,
            "repository": repo_name,
            "analysis": analysis_result,
            "timestamp": datetime.now().isoformat(),
            "analysis_type": analysis_type,
            "phase": "Phase 2 - Expansion"
        }
        
    except Exception as e:
        logger.error(f"Error in repository analysis: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error en análisis: {str(e)}")

@app.get("/repositories/supported")
async def get_supported_repositories():
    """Lista de repositorios soportados en Fase 2"""
    return {
        "supported_repositories": [
            {
                "name": "poc-billpay-back",
                "type": "Java Backend",
                "status": "✅ Completed (MVP)",
                "technologies": ["Java 17", "Spring Boot", "PostgreSQL"]
            },
            {
                "name": "poc-billpay-front-a",
                "type": "React Frontend",
                "status": "🔄 In Progress (Phase 2)",
                "technologies": ["React 18", "TypeScript", "Material-UI"]
            },
            {
                "name": "poc-billpay-front-b",
                "type": "React Frontend",
                "status": "⏳ Planned (Phase 2)",
                "technologies": ["React 18", "Alternative Design"]
            },
            {
                "name": "poc-billpay-front-feature-flags",
                "type": "React Frontend",
                "status": "⏳ Planned (Phase 2)",
                "technologies": ["React", "Feature Flags"]
            },
            {
                "name": "poc-icbs",
                "type": "Java Monolith",
                "status": "⏳ Planned (Phase 2)",
                "technologies": ["Java", "Spring Boot", "Oracle DB"]
            }
        ],
        "total_repositories": 5,
        "completed": 1,
        "in_progress": 1,
        "planned": 3
    }

@app.get("/analysis/stats")
async def get_analysis_stats():
    """Estadísticas de análisis de la Fase 2"""
    return {
        "phase": "Phase 2 - Expansion",
        "total_analyses": 2,  # MVP + Front-A
        "success_rate": "100%",
        "average_analysis_time": "< 5 seconds",
        "supported_languages": ["Java", "TypeScript", "JavaScript"],
        "supported_frameworks": ["Spring Boot", "React", "Material-UI"],
        "analysis_types": ["Backend API", "Frontend SPA", "Monolithic System"]
    }

# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    uvicorn.run(
        "main_phase2:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
