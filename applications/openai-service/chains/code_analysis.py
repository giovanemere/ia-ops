"""
Chain especializado para análisis de código
Utiliza LangChain para analizar repositorios y extraer información arquitectónica
"""

from typing import Dict, List, Any, Optional
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from langchain.schema import BaseOutputParser
import json
import structlog

logger = structlog.get_logger(__name__)

class CodeAnalysisOutputParser(BaseOutputParser):
    """Parser para estructurar la salida del análisis de código"""
    
    def parse(self, text: str) -> Dict[str, Any]:
        """Parsear la respuesta del LLM a formato estructurado"""
        try:
            # Intentar extraer información estructurada del texto
            analysis = {
                "technologies": self._extract_technologies(text),
                "architecture_pattern": self._extract_architecture_pattern(text),
                "components": self._extract_components(text),
                "dependencies": self._extract_dependencies(text),
                "code_quality": self._extract_code_quality(text),
                "recommendations": self._extract_recommendations(text),
                "raw_analysis": text
            }
            return analysis
        except Exception as e:
            logger.error("Failed to parse code analysis output", error=str(e))
            return {"raw_analysis": text, "error": str(e)}
    
    def _extract_technologies(self, text: str) -> List[Dict[str, str]]:
        """Extraer tecnologías identificadas"""
        technologies = []
        lines = text.split('\n')
        
        in_tech_section = False
        for line in lines:
            if "tecnologías" in line.lower() or "technologies" in line.lower():
                in_tech_section = True
                continue
            
            if in_tech_section and line.strip():
                if line.startswith('#') or line.startswith('##'):
                    in_tech_section = False
                    continue
                
                # Extraer tecnología de líneas como "- **Framework**: React 18"
                if '**' in line and ':' in line:
                    parts = line.split(':', 1)
                    if len(parts) == 2:
                        tech_type = parts[0].replace('*', '').replace('-', '').strip()
                        tech_name = parts[1].strip()
                        technologies.append({
                            "type": tech_type,
                            "name": tech_name,
                            "category": self._categorize_technology(tech_type)
                        })
        
        return technologies
    
    def _extract_architecture_pattern(self, text: str) -> Dict[str, str]:
        """Extraer patrón arquitectónico"""
        pattern = {"type": "Unknown", "description": ""}
        
        # Buscar patrones comunes
        patterns = {
            "microservicios": "Microservices",
            "microservice": "Microservices", 
            "monolito": "Monolithic",
            "monolithic": "Monolithic",
            "mvc": "MVC",
            "api-first": "API-First",
            "serverless": "Serverless",
            "event-driven": "Event-Driven"
        }
        
        text_lower = text.lower()
        for key, value in patterns.items():
            if key in text_lower:
                pattern["type"] = value
                break
        
        return pattern
    
    def _extract_components(self, text: str) -> List[str]:
        """Extraer componentes principales"""
        components = []
        lines = text.split('\n')
        
        in_components_section = False
        for line in lines:
            if "componentes" in line.lower() or "components" in line.lower():
                in_components_section = True
                continue
            
            if in_components_section and line.strip():
                if line.startswith('#') or line.startswith('##'):
                    in_components_section = False
                    continue
                
                if line.strip().startswith('-') or line.strip().startswith('*'):
                    component = line.strip().lstrip('-*').strip()
                    components.append(component)
        
        return components
    
    def _extract_dependencies(self, text: str) -> List[str]:
        """Extraer dependencias externas"""
        dependencies = []
        lines = text.split('\n')
        
        in_deps_section = False
        for line in lines:
            if "dependencias" in line.lower() or "dependencies" in line.lower():
                in_deps_section = True
                continue
            
            if in_deps_section and line.strip():
                if line.startswith('#') or line.startswith('##'):
                    in_deps_section = False
                    continue
                
                if line.strip().startswith('-') or line.strip().startswith('*'):
                    dependency = line.strip().lstrip('-*').strip()
                    dependencies.append(dependency)
        
        return dependencies
    
    def _extract_code_quality(self, text: str) -> Dict[str, Any]:
        """Extraer información de calidad de código"""
        quality = {
            "score": "Unknown",
            "issues": [],
            "strengths": []
        }
        
        # Buscar indicadores de calidad
        if "buena estructura" in text.lower() or "good structure" in text.lower():
            quality["strengths"].append("Good code structure")
        
        if "falta documentación" in text.lower() or "missing documentation" in text.lower():
            quality["issues"].append("Missing documentation")
        
        if "sin tests" in text.lower() or "no tests" in text.lower():
            quality["issues"].append("No unit tests")
        
        return quality
    
    def _extract_recommendations(self, text: str) -> List[str]:
        """Extraer recomendaciones"""
        recommendations = []
        lines = text.split('\n')
        
        in_recommendations_section = False
        for line in lines:
            if "recomendaciones" in line.lower() or "recommendations" in line.lower():
                in_recommendations_section = True
                continue
            
            if in_recommendations_section and line.strip():
                if line.startswith('#') or line.startswith('##'):
                    in_recommendations_section = False
                    continue
                
                if line.strip().startswith('-') or line.strip().startswith('*'):
                    recommendation = line.strip().lstrip('-*').strip()
                    recommendations.append(recommendation)
        
        return recommendations
    
    def _categorize_technology(self, tech_type: str) -> str:
        """Categorizar tecnología"""
        categories = {
            "framework": "Framework",
            "database": "Database",
            "frontend": "Frontend",
            "backend": "Backend",
            "library": "Library",
            "tool": "Tool",
            "language": "Language"
        }
        
        tech_lower = tech_type.lower()
        for key, value in categories.items():
            if key in tech_lower:
                return value
        
        return "Other"

class CodeAnalysisChain:
    """Chain especializado para análisis de código"""
    
    def __init__(self, llm):
        self.llm = llm
        self.output_parser = CodeAnalysisOutputParser()
        self.chain = self._create_chain()
    
    def _create_chain(self) -> LLMChain:
        """Crear el chain de análisis de código"""
        
        prompt_template = """
        Eres un arquitecto de software senior especializado en análisis de código. 
        Analiza el siguiente código y metadatos del proyecto de manera exhaustiva.

        **CÓDIGO A ANALIZAR:**
        ```
        {code_content}
        ```

        **METADATOS DEL PROYECTO:**
        {metadata}

        **ARCHIVOS ADICIONALES:**
        {additional_files}

        Proporciona un análisis detallado siguiendo esta estructura:

        ## 1. TECNOLOGÍAS IDENTIFICADAS
        Lista todas las tecnologías, frameworks y librerías encontradas:
        - **Framework Principal**: [Nombre y versión]
        - **Lenguaje**: [Lenguaje de programación]
        - **Base de Datos**: [Tipo de BD si se identifica]
        - **Frontend**: [Framework/librería frontend]
        - **Testing**: [Framework de testing]
        - **Build Tools**: [Herramientas de build]

        ## 2. PATRÓN ARQUITECTÓNICO
        Identifica el patrón arquitectónico principal:
        - **Tipo**: [MVC, Microservicios, Monolito, API-First, etc.]
        - **Descripción**: [Explicación del patrón identificado]
        - **Evidencia**: [Qué en el código indica este patrón]

        ## 3. COMPONENTES PRINCIPALES
        Lista los componentes/módulos principales:
        - [Componente 1]: [Descripción]
        - [Componente 2]: [Descripción]
        - [Componente 3]: [Descripción]

        ## 4. DEPENDENCIAS EXTERNAS
        Identifica dependencias y servicios externos:
        - [Dependencia 1]: [Propósito]
        - [Dependencia 2]: [Propósito]

        ## 5. CALIDAD DEL CÓDIGO
        Evalúa la calidad del código:
        - **Estructura**: [Evaluación de la organización]
        - **Documentación**: [Nivel de documentación]
        - **Testing**: [Cobertura de tests]
        - **Mejores Prácticas**: [Adherencia a estándares]

        ## 6. RECOMENDACIONES
        Proporciona recomendaciones específicas:
        - [Recomendación 1]: [Justificación]
        - [Recomendación 2]: [Justificación]
        - [Recomendación 3]: [Justificación]

        ## 7. MÉTRICAS ESTIMADAS
        - **Complejidad**: [Baja/Media/Alta]
        - **Mantenibilidad**: [Baja/Media/Alta]
        - **Escalabilidad**: [Baja/Media/Alta]
        - **Tiempo de Desarrollo Estimado**: [Estimación]

        Sé específico y técnico en tu análisis, pero mantén las explicaciones claras.
        """
        
        prompt = PromptTemplate(
            input_variables=["code_content", "metadata", "additional_files"],
            template=prompt_template,
            output_parser=self.output_parser
        )
        
        return LLMChain(llm=self.llm, prompt=prompt, output_parser=self.output_parser)
    
    async def analyze(self, code_content: str, metadata: Dict[str, Any], 
                     additional_files: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Ejecutar análisis de código
        
        Args:
            code_content: Contenido del código principal
            metadata: Metadatos del proyecto (package.json, etc.)
            additional_files: Archivos adicionales relevantes
        
        Returns:
            Análisis estructurado del código
        """
        try:
            # Preparar archivos adicionales
            files_content = ""
            if additional_files:
                for filename, content in additional_files.items():
                    files_content += f"\n**{filename}:**\n```\n{content}\n```\n"
            
            # Ejecutar el chain
            result = await self.chain.arun(
                code_content=code_content,
                metadata=json.dumps(metadata, indent=2),
                additional_files=files_content
            )
            
            logger.info("Code analysis completed successfully")
            return result
            
        except Exception as e:
            logger.error("Code analysis failed", error=str(e))
            return {
                "error": str(e),
                "raw_analysis": f"Error en el análisis: {str(e)}"
            }
    
    def get_analysis_summary(self, analysis: Dict[str, Any]) -> str:
        """Generar resumen del análisis"""
        try:
            technologies = analysis.get("technologies", [])
            pattern = analysis.get("architecture_pattern", {})
            components = analysis.get("components", [])
            
            summary = f"""
            ## Resumen del Análisis
            
            **Tecnologías principales**: {', '.join([t.get('name', '') for t in technologies[:3]])}
            **Patrón arquitectónico**: {pattern.get('type', 'Unknown')}
            **Componentes**: {len(components)} identificados
            **Recomendaciones**: {len(analysis.get('recommendations', []))} sugerencias
            """
            
            return summary.strip()
            
        except Exception as e:
            logger.error("Failed to generate analysis summary", error=str(e))
            return "Error generando resumen del análisis"
