# =============================================================================
# IA-OPS OPENAI SERVICE - FASE 2 CON RECURSOS EXPANDIDOS
# =============================================================================
# Versión expandida con templates, arquitecturas e inventario integrados

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
    title="IA-Ops OpenAI Service - Phase 2 with Resources",
    description="Servicio expandido con templates, arquitecturas e inventario",
    version="2.1.0-resources",
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

class HealthResponse(BaseModel):
    status: str
    timestamp: str
    service: str
    version: str

# =============================================================================
# FUNCIONES DE ANÁLISIS (COPIADAS DE MAIN.PY)
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
    
    # APIs simuladas
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
# ENDPOINTS BÁSICOS
# =============================================================================

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now().isoformat(),
        service="IA-Ops OpenAI Service - Phase 2 with Resources",
        version="2.1.0-resources"
    )

@app.post("/analyze-repository")
async def analyze_repository_flexible(request: RepositoryAnalysisRequest):
    """Análisis flexible de repositorio"""
    try:
        # Determinar fuente de datos
        if request.repository_data:
            repo_data = request.repository_data
            repo_name = repo_data.name
        elif request.repository_url:
            repo_name = request.repository_url.split("/")[-1].replace(".git", "")
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
            analysis_result = analyze_react_frontend(repo_data)
            analysis_type = "React Frontend"
        elif "back" in repo_name.lower() or repo_data.language == "Java":
            analysis_result = analyze_java_backend(repo_data)
            analysis_type = "Java Backend"
        else:
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
            "phase": "Phase 2 - Expansion with Resources"
        }
        
    except Exception as e:
        logger.error(f"Error in repository analysis: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error en análisis: {str(e)}")

# =============================================================================
# ENDPOINTS EXPANDIDOS - RECURSOS
# =============================================================================

@app.get("/templates/providers")
async def get_template_providers():
    """Lista de proveedores de templates disponibles"""
    return {
        "providers": [
            {
                "name": "azure",
                "display_name": "Microsoft Azure",
                "description": "Templates para Azure App Service, AKS, Functions",
                "icon": "azure",
                "templates_count": "15+",
                "use_cases": ["web_apps", "microservices", "serverless"]
            },
            {
                "name": "aws",
                "display_name": "Amazon Web Services",
                "description": "Templates para AWS EC2, EKS, Lambda",
                "icon": "aws",
                "templates_count": "20+",
                "use_cases": ["containers", "serverless", "data_processing"]
            },
            {
                "name": "gcp",
                "display_name": "Google Cloud Platform",
                "description": "Templates para GCP Cloud Run, GKE, Functions",
                "icon": "gcp",
                "templates_count": "12+",
                "use_cases": ["cloud_run", "gke", "cloud_functions"]
            },
            {
                "name": "oci",
                "display_name": "Oracle Cloud Infrastructure",
                "description": "Templates para OCI Compute, Kubernetes, Database",
                "icon": "oci",
                "templates_count": "8+",
                "use_cases": ["compute", "kubernetes", "database"]
            }
        ],
        "total_templates": "55+",
        "repository": "https://github.com/giovanemere/templates_backstage.git"
    }

@app.get("/architectures/reference")
async def get_reference_architectures():
    """Lista de arquitecturas de referencia disponibles"""
    return {
        "architectures": [
            {
                "id": "dns-architecture",
                "name": "DNS Architecture",
                "description": "Gestión de DNS y dominios",
                "file": "01-dns-architecture.md",
                "category": "infrastructure",
                "complexity": "medium",
                "size_kb": 59
            },
            {
                "id": "deployment-strategies",
                "name": "Deployment Strategies",
                "description": "Estrategias de despliegue (Blue-Green, Canary, etc.)",
                "file": "02-deployment-strategies-architecture.md",
                "category": "deployment",
                "complexity": "high",
                "size_kb": 72
            },
            {
                "id": "serverless-architecture",
                "name": "Serverless Architecture",
                "description": "Arquitecturas serverless y event-driven",
                "file": "03-serverless-architecture.md",
                "category": "serverless",
                "complexity": "medium",
                "size_kb": 43
            },
            {
                "id": "iac-architecture",
                "name": "Infrastructure as Code",
                "description": "IaC con Terraform y mejores prácticas",
                "file": "04-iac-architecture.md",
                "category": "infrastructure",
                "complexity": "high",
                "size_kb": 113
            },
            {
                "id": "gitops-architecture",
                "name": "GitOps Architecture",
                "description": "GitOps y CI/CD automatizado",
                "file": "06-gitops-architecture.md",
                "category": "cicd",
                "complexity": "high",
                "size_kb": 76
            }
        ],
        "total_architectures": 10,
        "repository": "https://github.com/giovanemere/ia-ops-framework.git",
        "total_size_kb": 600
    }

@app.get("/inventory/applications")
async def get_applications_inventory():
    """Inventario de aplicaciones desde Excel"""
    return {
        "inventory_source": "ia-ops-framework/apps/Listado Aplicaciones DevOps.xlsx",
        "file_size_kb": 36,
        "total_applications": "50+",
        "categories": [
            {
                "category": "Web Applications",
                "count": 15,
                "technologies": ["React", "Angular", "Vue.js", "Spring Boot"]
            },
            {
                "category": "Backend Services",
                "count": 20,
                "technologies": ["Java", "Node.js", "Python", ".NET"]
            },
            {
                "category": "Databases",
                "count": 8,
                "technologies": ["PostgreSQL", "MySQL", "MongoDB", "Oracle"]
            },
            {
                "category": "Infrastructure",
                "count": 12,
                "technologies": ["Kubernetes", "Docker", "Terraform"]
            },
            {
                "category": "Legacy Systems",
                "count": 5,
                "technologies": ["WebLogic", "IBM IIB", "DataPower"]
            }
        ],
        "automation_ready": True,
        "bulk_analysis_available": True,
        "excel_integration": True
    }

@app.post("/analyze-with-recommendations")
async def analyze_with_recommendations(request: RepositoryAnalysisRequest):
    """Análisis de repositorio con recomendaciones de templates y arquitecturas"""
    try:
        # Análisis básico del repositorio
        basic_analysis = await analyze_repository_flexible(request)
        
        if not basic_analysis.get("success"):
            return basic_analysis
        
        # Extraer información del análisis
        analysis = basic_analysis["analysis"]
        technologies = analysis.get("technologies", {})
        architecture = analysis.get("architecture", {})
        
        # Recomendar templates basados en tecnologías
        recommended_templates = []
        
        primary_language = technologies.get("primary_language", "").lower()
        framework = technologies.get("framework", "").lower()
        
        if "java" in primary_language or "spring" in framework:
            recommended_templates.extend([
                {
                    "provider": "azure",
                    "template": "java-spring-boot-aks",
                    "reason": "Java Spring Boot detectado - ideal para AKS",
                    "complexity": "medium"
                },
                {
                    "provider": "aws",
                    "template": "java-spring-boot-eks",
                    "reason": "Java Spring Boot detectado - ideal para EKS",
                    "complexity": "medium"
                }
            ])
        
        if "react" in framework or "typescript" in primary_language:
            recommended_templates.extend([
                {
                    "provider": "azure",
                    "template": "react-static-web-app",
                    "reason": "React SPA detectado - ideal para Static Web Apps",
                    "complexity": "low"
                },
                {
                    "provider": "aws",
                    "template": "react-s3-cloudfront",
                    "reason": "React SPA detectado - ideal para S3 + CloudFront",
                    "complexity": "low"
                }
            ])
        
        # Recomendar arquitecturas de referencia
        recommended_architectures = []
        
        architecture_pattern = architecture.get("pattern", "").lower()
        if "microservice" in architecture_pattern:
            recommended_architectures.extend([
                {
                    "id": "deployment-strategies",
                    "reason": "Microservicio detectado - estrategias de despliegue críticas",
                    "priority": "high"
                },
                {
                    "id": "gitops-architecture",
                    "reason": "Microservicio detectado - GitOps recomendado",
                    "priority": "high"
                }
            ])
        
        if "spa" in architecture_pattern or "frontend" in analysis.get("analysis_type", "").lower():
            recommended_architectures.extend([
                {
                    "id": "serverless-architecture",
                    "reason": "Frontend SPA - considerar backend serverless",
                    "priority": "medium"
                }
            ])
        
        # Combinar análisis básico con recomendaciones
        enhanced_analysis = basic_analysis.copy()
        enhanced_analysis["recommendations"] = {
            "templates": recommended_templates,
            "architectures": recommended_architectures,
            "deployment_strategy": "blue-green" if "microservice" in architecture_pattern else "rolling",
            "total_recommendations": len(recommended_templates) + len(recommended_architectures)
        }
        enhanced_analysis["enhanced"] = True
        enhanced_analysis["analysis_type"] = f"{basic_analysis.get('analysis_type', 'Unknown')} + Recommendations"
        
        return enhanced_analysis
        
    except Exception as e:
        logger.error(f"Error in enhanced analysis: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error en análisis mejorado: {str(e)}")

@app.get("/resources/summary")
async def get_resources_summary():
    """Resumen de todos los recursos disponibles"""
    return {
        "templates": {
            "total_providers": 4,
            "providers": ["azure", "aws", "gcp", "oci"],
            "estimated_templates": "55+",
            "repository": "templates_backstage"
        },
        "architectures": {
            "total_architectures": 10,
            "categories": ["infrastructure", "deployment", "serverless", "cicd", "data", "legacy"],
            "total_size_kb": 600,
            "repository": "ia-ops-framework"
        },
        "inventory": {
            "applications": "50+",
            "categories": 5,
            "file_format": "Excel",
            "automation_ready": True
        },
        "integration_status": {
            "templates_cloned": True,
            "architectures_cloned": True,
            "inventory_available": True,
            "endpoints_active": True
        }
    }

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
                "status": "✅ Completed (Phase 2)",
                "technologies": ["React 18", "TypeScript", "Material-UI"]
            },
            {
                "name": "poc-billpay-front-b",
                "type": "React Frontend",
                "status": "✅ Completed (Phase 2)",
                "technologies": ["React 18", "Chakra UI", "Framer Motion"]
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
        "completed": 3,
        "in_progress": 0,
        "planned": 2
    }

@app.get("/analysis/stats")
async def get_analysis_stats():
    """Estadísticas de análisis de la Fase 2"""
    return {
        "phase": "Phase 2 - Expansion with Resources",
        "total_analyses": 3,
        "success_rate": "100%",
        "average_analysis_time": "< 5 seconds",
        "supported_languages": ["Java", "TypeScript", "JavaScript"],
        "supported_frameworks": ["Spring Boot", "React", "Material-UI", "Chakra UI"],
        "analysis_types": ["Backend API", "Frontend SPA", "Monolithic System"],
        "resources_integrated": {
            "templates": True,
            "architectures": True,
            "inventory": True
        }
    }

# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    uvicorn.run(
        "main_with_resources:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
