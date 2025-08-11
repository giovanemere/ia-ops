# =============================================================================
# ENDPOINTS EXPANDIDOS - FASE 2
# =============================================================================
# Nuevos endpoints para templates, arquitecturas e inventario

from fastapi import HTTPException
from typing import Dict, Any, List
import logging

logger = logging.getLogger(__name__)

def add_expanded_endpoints(app):
    """Agregar endpoints expandidos a la aplicación FastAPI"""
    
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
                    "id": "onpremise-architecture",
                    "name": "On-Premise Architecture",
                    "description": "Arquitecturas on-premise y híbridas",
                    "file": "05-onpremise-architecture.md",
                    "category": "infrastructure",
                    "complexity": "high",
                    "size_kb": 92
                },
                {
                    "id": "gitops-architecture",
                    "name": "GitOps Architecture",
                    "description": "GitOps y CI/CD automatizado",
                    "file": "06-gitops-architecture.md",
                    "category": "cicd",
                    "complexity": "high",
                    "size_kb": 76
                },
                {
                    "id": "database-architecture",
                    "name": "Database Architecture",
                    "description": "Arquitecturas de base de datos",
                    "file": "07-database-architecture.md",
                    "category": "data",
                    "complexity": "medium",
                    "size_kb": 39
                },
                {
                    "id": "weblogic-architecture",
                    "name": "WebLogic Architecture",
                    "description": "Sistemas WebLogic legacy",
                    "file": "08-weblogic-architecture.md",
                    "category": "legacy",
                    "complexity": "high",
                    "size_kb": 51
                },
                {
                    "id": "other-architectures",
                    "name": "Other Architectures",
                    "description": "Patrones adicionales y casos especiales",
                    "file": "09-other-architectures.md",
                    "category": "patterns",
                    "complexity": "medium",
                    "size_kb": 45
                },
                {
                    "id": "diagrams-as-code",
                    "name": "Diagrams as Code",
                    "description": "Mejores prácticas para diagramas como código",
                    "file": "10-diagrams-as-code-best-practices.md",
                    "category": "documentation",
                    "complexity": "low",
                    "size_kb": 10
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
    async def analyze_with_recommendations(request):
        """Análisis de repositorio con recomendaciones de templates y arquitecturas"""
        try:
            # Importar la función de análisis básico
            from main import analyze_repository_flexible
            
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
            
            # Lógica de recomendación
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
                    },
                    {
                        "id": "dns-architecture",
                        "reason": "Frontend SPA - configuración DNS importante",
                        "priority": "low"
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

    return app
