# =============================================================================
# ANÁLISIS SIMPLE DE REPOSITORIO - MVP EMERGENCIA
# =============================================================================
# Implementación directa con OpenAI API para demo en 8 horas

import json
import os
import requests
from datetime import datetime
from typing import Dict, Any, Optional
import openai
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configurar OpenAI
openai.api_key = os.getenv("OPENAI_API_KEY")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
DEMO_MODE = os.getenv("DEMO_MODE", "true").lower() == "true"

class SimpleRepositoryAnalyzer:
    """Analizador simple de repositorios para MVP"""
    
    def __init__(self):
        self.demo_mode = DEMO_MODE
        
    async def analyze_repository_simple(self, repo_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Análisis simple de repositorio con datos proporcionados
        Para MVP: no clona repo, usa datos proporcionados
        """
        try:
            # Extraer información básica
            package_json = repo_data.get("package_json", {})
            readme = repo_data.get("readme", "")
            repo_name = repo_data.get("name", "unknown-repo")
            
            # Crear prompt estructurado para análisis
            analysis_prompt = self._create_analysis_prompt(package_json, readme, repo_name)
            
            # Ejecutar análisis con OpenAI
            if self.demo_mode:
                # Modo demo: respuesta simulada
                analysis_result = self._get_demo_analysis(repo_name, package_json)
            else:
                # Modo real: llamada a OpenAI
                analysis_result = await self._call_openai_analysis(analysis_prompt)
            
            # Estructurar respuesta
            return {
                "success": True,
                "repository": repo_name,
                "analysis": analysis_result,
                "timestamp": datetime.now().isoformat(),
                "mode": "demo" if self.demo_mode else "real"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "repository": repo_data.get("name", "unknown"),
                "timestamp": datetime.now().isoformat()
            }
    
    def _create_analysis_prompt(self, package_json: Dict, readme: str, repo_name: str) -> str:
        """Crear prompt estructurado para análisis"""
        
        prompt = f"""
Analiza este repositorio de software y proporciona un análisis detallado en formato JSON.

REPOSITORIO: {repo_name}

PACKAGE.JSON:
{json.dumps(package_json, indent=2) if package_json else "No disponible"}

README:
{readme[:1000] if readme else "No disponible"}

Por favor, analiza y retorna un JSON con la siguiente estructura:

{{
  "technologies": {{
    "primary_language": "lenguaje principal",
    "framework": "framework principal",
    "runtime": "runtime/plataforma",
    "database": "base de datos si se identifica",
    "dependencies": ["lista", "de", "dependencias", "principales"]
  }},
  "architecture": {{
    "type": "tipo de arquitectura (microservicio, monolito, spa, etc.)",
    "pattern": "patrón arquitectónico identificado",
    "description": "descripción de la arquitectura"
  }},
  "components": {{
    "apis": ["endpoints", "o", "apis", "identificadas"],
    "services": ["servicios", "identificados"],
    "databases": ["bases", "de", "datos"],
    "external_services": ["servicios", "externos"]
  }},
  "recommendations": {{
    "deployment": "estrategia de despliegue recomendada",
    "scaling": "recomendaciones de escalabilidad",
    "monitoring": "métricas clave a monitorear",
    "security": "consideraciones de seguridad"
  }},
  "documentation": {{
    "quality": "calidad de documentación (1-5)",
    "missing": ["elementos", "faltantes", "en", "documentación"],
    "suggestions": ["sugerencias", "de", "mejora"]
  }}
}}

Responde SOLO con el JSON, sin texto adicional.
"""
        return prompt
    
    async def _call_openai_analysis(self, prompt: str) -> Dict[str, Any]:
        """Llamada real a OpenAI API"""
        try:
            response = await openai.ChatCompletion.acreate(
                model=OPENAI_MODEL,
                messages=[
                    {"role": "system", "content": "Eres un experto en análisis de arquitectura de software. Respondes siempre en formato JSON válido."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=2000
            )
            
            # Extraer y parsear respuesta
            content = response.choices[0].message.content
            return json.loads(content)
            
        except json.JSONDecodeError:
            # Si no es JSON válido, crear estructura básica
            return self._create_fallback_analysis(content)
        except Exception as e:
            raise Exception(f"OpenAI API error: {str(e)}")
    
    def _get_demo_analysis(self, repo_name: str, package_json: Dict) -> Dict[str, Any]:
        """Análisis demo para poc-billpay-back"""
        
        # Detectar tecnologías del package.json
        dependencies = package_json.get("dependencies", {})
        dev_dependencies = package_json.get("devDependencies", {})
        
        # Análisis específico para BillPay Backend
        if "billpay" in repo_name.lower() and "back" in repo_name.lower():
            return {
                "technologies": {
                    "primary_language": "JavaScript",
                    "framework": "Express.js",
                    "runtime": "Node.js",
                    "database": "PostgreSQL",
                    "dependencies": list(dependencies.keys())[:10]  # Top 10
                },
                "architecture": {
                    "type": "API-First Microservice",
                    "pattern": "RESTful API with MVC Pattern",
                    "description": "Microservicio backend para sistema de pagos con arquitectura API-first"
                },
                "components": {
                    "apis": ["/api/payments", "/api/users", "/api/transactions", "/api/auth"],
                    "services": ["PaymentService", "UserService", "AuthService", "TransactionService"],
                    "databases": ["PostgreSQL (primary)", "Redis (cache)"],
                    "external_services": ["Payment Gateway", "Email Service", "SMS Service"]
                },
                "recommendations": {
                    "deployment": "Blue-Green Deployment (zero downtime crítico para pagos)",
                    "scaling": "Horizontal scaling con load balancer, auto-scaling basado en CPU/memoria",
                    "monitoring": "Payment success rate >99.9%, Response time <200ms, Error rate <0.1%",
                    "security": "JWT authentication, API rate limiting, Input validation, HTTPS only"
                },
                "documentation": {
                    "quality": 3,
                    "missing": ["API documentation", "Architecture diagrams", "Deployment guide"],
                    "suggestions": ["Swagger/OpenAPI docs", "Mermaid architecture diagrams", "Docker setup guide"]
                }
            }
        
        # Análisis genérico para otros repos
        return {
            "technologies": {
                "primary_language": "JavaScript" if dependencies else "Unknown",
                "framework": self._detect_framework(dependencies),
                "runtime": "Node.js" if dependencies else "Unknown",
                "database": "Not detected",
                "dependencies": list(dependencies.keys())[:5]
            },
            "architecture": {
                "type": "Web Application",
                "pattern": "Standard Web App Pattern",
                "description": f"Aplicación web estándar - {repo_name}"
            },
            "components": {
                "apis": ["To be analyzed"],
                "services": ["To be analyzed"],
                "databases": ["To be analyzed"],
                "external_services": ["To be analyzed"]
            },
            "recommendations": {
                "deployment": "Standard deployment with CI/CD",
                "scaling": "Monitor usage and scale accordingly",
                "monitoring": "Basic application metrics",
                "security": "Standard security practices"
            },
            "documentation": {
                "quality": 2,
                "missing": ["Detailed analysis needed"],
                "suggestions": ["Provide more repository data for detailed analysis"]
            }
        }
    
    def _detect_framework(self, dependencies: Dict) -> str:
        """Detectar framework principal de las dependencias"""
        if "express" in dependencies:
            return "Express.js"
        elif "react" in dependencies:
            return "React"
        elif "vue" in dependencies:
            return "Vue.js"
        elif "angular" in dependencies:
            return "Angular"
        elif "fastapi" in dependencies:
            return "FastAPI"
        elif "django" in dependencies:
            return "Django"
        else:
            return "Unknown"
    
    def _create_fallback_analysis(self, content: str) -> Dict[str, Any]:
        """Crear análisis básico si OpenAI no retorna JSON válido"""
        return {
            "technologies": {
                "primary_language": "Unknown",
                "framework": "Unknown",
                "runtime": "Unknown",
                "database": "Unknown",
                "dependencies": []
            },
            "architecture": {
                "type": "Unknown",
                "pattern": "Unknown",
                "description": "Analysis failed - invalid response format"
            },
            "components": {
                "apis": [],
                "services": [],
                "databases": [],
                "external_services": []
            },
            "recommendations": {
                "deployment": "Standard deployment",
                "scaling": "Monitor and scale as needed",
                "monitoring": "Basic monitoring",
                "security": "Standard security practices"
            },
            "documentation": {
                "quality": 1,
                "missing": ["Complete analysis"],
                "suggestions": ["Retry analysis with better data"]
            },
            "raw_response": content[:500]  # Primeros 500 chars para debug
        }

# Instancia global del analizador
simple_analyzer = SimpleRepositoryAnalyzer()
