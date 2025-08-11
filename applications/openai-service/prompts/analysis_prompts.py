"""
Prompts especializados para análisis de código y arquitectura
Colección de templates optimizados para diferentes tipos de análisis
"""

from langchain.prompts import PromptTemplate
from typing import Dict, Any

class AnalysisPrompts:
    """Colección de prompts especializados para análisis"""
    
    @staticmethod
    def get_code_analysis_prompt() -> PromptTemplate:
        """Prompt para análisis general de código"""
        template = """
        Eres un arquitecto de software senior con 15+ años de experiencia. 
        Analiza el siguiente código de manera exhaustiva y profesional.

        **CÓDIGO:**
        ```{language}
        {code_content}
        ```

        **METADATOS:**
        {metadata}

        **CONTEXTO DEL PROYECTO:**
        - Tipo: {project_type}
        - Dominio: {domain}
        - Tamaño estimado: {project_size}

        Proporciona un análisis técnico detallado:

        ## ANÁLISIS TÉCNICO

        ### 1. Stack Tecnológico
        - **Lenguaje Principal**: [Versión específica]
        - **Framework/Runtime**: [Con versiones]
        - **Base de Datos**: [Tipo y configuración]
        - **Dependencias Clave**: [Top 5 más importantes]

        ### 2. Arquitectura y Patrones
        - **Patrón Arquitectónico**: [Identificado con evidencia]
        - **Patrones de Diseño**: [Observados en el código]
        - **Estructura de Directorios**: [Evaluación]
        - **Separación de Responsabilidades**: [Análisis]

        ### 3. Calidad y Mantenibilidad
        - **Complejidad Ciclomática**: [Estimación]
        - **Cobertura de Tests**: [Evaluación]
        - **Documentación**: [Nivel actual]
        - **Adherencia a Estándares**: [Evaluación]

        ### 4. Performance y Escalabilidad
        - **Bottlenecks Potenciales**: [Identificados]
        - **Estrategias de Caching**: [Implementadas]
        - **Manejo de Concurrencia**: [Evaluación]
        - **Escalabilidad Horizontal**: [Posibilidades]

        ### 5. Seguridad
        - **Vulnerabilidades Potenciales**: [Identificadas]
        - **Autenticación/Autorización**: [Implementación]
        - **Validación de Datos**: [Evaluación]
        - **Manejo de Secretos**: [Análisis]

        ### 6. DevOps y Deployment
        - **Containerización**: [Estado actual]
        - **CI/CD Readiness**: [Evaluación]
        - **Monitoreo**: [Implementación]
        - **Logging**: [Estrategia actual]

        ## RECOMENDACIONES PRIORIZADAS

        ### Críticas (Implementar inmediatamente)
        1. [Recomendación crítica 1]
        2. [Recomendación crítica 2]

        ### Importantes (Próximas 2 semanas)
        1. [Recomendación importante 1]
        2. [Recomendación importante 2]

        ### Mejoras (Roadmap a mediano plazo)
        1. [Mejora 1]
        2. [Mejora 2]

        ## ESTIMACIONES

        - **Esfuerzo de Refactoring**: [Horas/días estimados]
        - **Complejidad de Mantenimiento**: [1-10]
        - **Tiempo para Producción**: [Estimación]
        - **Costo de Infraestructura**: [Estimación mensual]

        Sé específico, técnico y proporciona ejemplos de código cuando sea relevante.
        """
        
        return PromptTemplate(
            input_variables=[
                "language", "code_content", "metadata", 
                "project_type", "domain", "project_size"
            ],
            template=template
        )
    
    @staticmethod
    def get_architecture_recommendation_prompt() -> PromptTemplate:
        """Prompt para recomendaciones arquitectónicas"""
        template = """
        Eres un arquitecto de soluciones enterprise con experiencia en modernización de aplicaciones.
        
        **ANÁLISIS DE CÓDIGO ACTUAL:**
        {code_analysis}

        **ARQUITECTURAS DE REFERENCIA DISPONIBLES:**
        {reference_architectures}

        **REQUISITOS DEL NEGOCIO:**
        - Usuarios concurrentes: {concurrent_users}
        - Disponibilidad requerida: {availability_requirement}
        - Presupuesto: {budget_constraint}
        - Timeline: {timeline}
        - Compliance: {compliance_requirements}

        **CONTEXTO ORGANIZACIONAL:**
        - Tamaño del equipo: {team_size}
        - Experiencia técnica: {team_experience}
        - Infraestructura actual: {current_infrastructure}
        - Restricciones tecnológicas: {tech_constraints}

        Proporciona una recomendación arquitectónica completa:

        ## RECOMENDACIÓN ARQUITECTÓNICA

        ### 1. Arquitectura Objetivo
        - **Patrón Recomendado**: [Nombre específico]
        - **Justificación Técnica**: [Por qué es la mejor opción]
        - **Justificación de Negocio**: [Beneficios empresariales]

        ### 2. Diagrama de Arquitectura
        ```mermaid
        [Diagrama Mermaid detallado de la arquitectura]
        ```

        ### 3. Componentes Principales
        | Componente | Responsabilidad | Tecnología Sugerida | Justificación |
        |------------|-----------------|---------------------|---------------|
        | [Comp 1]   | [Función]       | [Tech]              | [Por qué]     |
        | [Comp 2]   | [Función]       | [Tech]              | [Por qué]     |

        ### 4. Estrategia de Datos
        - **Patrón de Datos**: [Database per service, Shared DB, etc.]
        - **Tecnologías de BD**: [Específicas con justificación]
        - **Estrategia de Migración**: [Paso a paso]
        - **Backup y Recovery**: [Estrategia]

        ### 5. Integración y APIs
        - **Patrón de Integración**: [REST, GraphQL, Event-driven]
        - **API Gateway**: [Necesidad y configuración]
        - **Autenticación**: [OAuth2, JWT, etc.]
        - **Rate Limiting**: [Estrategia]

        ### 6. Infraestructura y Deployment
        - **Containerización**: [Docker, Kubernetes]
        - **Orquestación**: [K8s, Docker Swarm, etc.]
        - **Service Mesh**: [Istio, Linkerd, necesario?]
        - **Monitoring**: [Prometheus, Grafana, etc.]

        ## PLAN DE MIGRACIÓN

        ### Fase 1: Preparación (Semanas 1-2)
        - [ ] [Tarea específica 1]
        - [ ] [Tarea específica 2]

        ### Fase 2: Implementación Core (Semanas 3-6)
        - [ ] [Tarea específica 1]
        - [ ] [Tarea específica 2]

        ### Fase 3: Migración de Datos (Semanas 7-8)
        - [ ] [Tarea específica 1]
        - [ ] [Tarea específica 2]

        ### Fase 4: Go-Live y Optimización (Semanas 9-10)
        - [ ] [Tarea específica 1]
        - [ ] [Tarea específica 2]

        ## ANÁLISIS DE RIESGOS

        ### Riesgos Altos
        | Riesgo | Probabilidad | Impacto | Mitigación |
        |--------|--------------|---------|------------|
        | [Riesgo 1] | [Alta/Media/Baja] | [Alto/Medio/Bajo] | [Estrategia] |

        ### Riesgos Medios
        | Riesgo | Probabilidad | Impacto | Mitigación |
        |--------|--------------|---------|------------|
        | [Riesgo 1] | [Alta/Media/Baja] | [Alto/Medio/Bajo] | [Estrategia] |

        ## ESTIMACIONES Y COSTOS

        ### Desarrollo
        - **Esfuerzo Total**: [Persona-meses]
        - **Costo de Desarrollo**: [Estimación]
        - **Timeline**: [Meses]

        ### Infraestructura
        - **Costo Mensual Estimado**: [USD]
        - **Costo de Migración**: [USD one-time]
        - **ROI Esperado**: [Timeframe]

        ## MÉTRICAS DE ÉXITO

        ### Técnicas
        - Response time < [X]ms
        - Availability > [X]%
        - Throughput > [X] RPS

        ### Negocio
        - Time to market reducido en [X]%
        - Costo operativo reducido en [X]%
        - Developer productivity aumentada en [X]%

        Proporciona recomendaciones específicas, prácticas y ejecutables.
        """
        
        return PromptTemplate(
            input_variables=[
                "code_analysis", "reference_architectures", "concurrent_users",
                "availability_requirement", "budget_constraint", "timeline",
                "compliance_requirements", "team_size", "team_experience",
                "current_infrastructure", "tech_constraints"
            ],
            template=template
        )
    
    @staticmethod
    def get_documentation_generation_prompt() -> PromptTemplate:
        """Prompt para generación de documentación"""
        template = """
        Eres un technical writer senior especializado en documentación de software enterprise.
        
        **ANÁLISIS DE CÓDIGO:**
        {code_analysis}

        **RECOMENDACIÓN ARQUITECTÓNICA:**
        {architecture_recommendation}

        **TIPO DE DOCUMENTACIÓN:** {doc_type}
        **AUDIENCIA:** {target_audience}
        **NIVEL TÉCNICO:** {technical_level}

        Genera documentación técnica completa y profesional:

        # {project_name}

        ## 📋 Descripción del Proyecto

        ### Propósito
        [Descripción clara del propósito y valor del proyecto]

        ### Funcionalidades Principales
        - [Funcionalidad 1]: [Descripción]
        - [Funcionalidad 2]: [Descripción]
        - [Funcionalidad 3]: [Descripción]

        ### Audiencia Objetivo
        [Quién usará este sistema y cómo]

        ## 🏗️ Arquitectura

        ### Diagrama de Arquitectura
        ```mermaid
        [Diagrama Mermaid de la arquitectura completa]
        ```

        ### Componentes del Sistema
        | Componente | Responsabilidad | Tecnología | Puerto/Endpoint |
        |------------|-----------------|------------|-----------------|
        | [Comp 1]   | [Función]       | [Tech]     | [Puerto]        |
        | [Comp 2]   | [Función]       | [Tech]     | [Puerto]        |

        ### Flujo de Datos
        ```mermaid
        [Diagrama de flujo de datos]
        ```

        ## 🛠️ Stack Tecnológico

        ### Backend
        - **Runtime**: [Tecnología y versión]
        - **Framework**: [Framework principal]
        - **Base de Datos**: [BD principal y auxiliares]
        - **Cache**: [Solución de cache]

        ### Frontend
        - **Framework**: [React, Angular, etc.]
        - **UI Library**: [Material-UI, etc.]
        - **State Management**: [Redux, etc.]
        - **Build Tool**: [Webpack, Vite, etc.]

        ### DevOps
        - **Containerización**: [Docker, etc.]
        - **Orquestación**: [Kubernetes, etc.]
        - **CI/CD**: [Jenkins, GitHub Actions, etc.]
        - **Monitoreo**: [Prometheus, etc.]

        ## 🚀 Instalación y Configuración

        ### Prerrequisitos
        ```bash
        # Listar todos los prerrequisitos con versiones específicas
        ```

        ### Instalación Local
        ```bash
        # Paso 1: Clonar repositorio
        git clone [repo-url]
        cd [project-name]

        # Paso 2: Configurar variables de entorno
        cp .env.example .env
        # Editar .env con configuraciones específicas

        # Paso 3: Instalar dependencias
        [comandos específicos]

        # Paso 4: Inicializar base de datos
        [comandos de migración]

        # Paso 5: Iniciar servicios
        [comandos de inicio]
        ```

        ### Configuración de Producción
        ```yaml
        # Configuraciones específicas para producción
        ```

        ## 📡 API Documentation

        ### Endpoints Principales

        #### Autenticación
        ```http
        POST /api/auth/login
        Content-Type: application/json

        {
          "email": "user@example.com",
          "password": "password"
        }
        ```

        #### [Otros endpoints principales]

        ### Códigos de Respuesta
        | Código | Descripción | Ejemplo |
        |--------|-------------|---------|
        | 200    | Success     | [Ejemplo] |
        | 400    | Bad Request | [Ejemplo] |
        | 401    | Unauthorized| [Ejemplo] |

        ## 🚢 Deployment

        ### Desarrollo Local
        ```bash
        [Comandos para desarrollo local]
        ```

        ### Staging
        ```bash
        [Comandos para staging]
        ```

        ### Producción
        ```bash
        [Comandos para producción]
        ```

        ### Docker Compose
        ```yaml
        # docker-compose.yml ejemplo
        ```

        ### Kubernetes
        ```yaml
        # Manifiestos K8s ejemplo
        ```

        ## 📊 Monitoreo y Observabilidad

        ### Métricas Clave
        - **Performance**: Response time, throughput
        - **Disponibilidad**: Uptime, error rate
        - **Recursos**: CPU, memoria, disco

        ### Dashboards
        - **Grafana**: [URL y descripción]
        - **Prometheus**: [Métricas específicas]

        ### Logs
        ```bash
        # Comandos para acceder a logs
        ```

        ### Alertas
        | Alerta | Condición | Acción |
        |--------|-----------|--------|
        | [Alerta 1] | [Condición] | [Acción] |

        ## 🔧 Troubleshooting

        ### Problemas Comunes

        #### Error: [Descripción del error]
        **Síntomas**: [Cómo se manifiesta]
        **Causa**: [Causa probable]
        **Solución**:
        ```bash
        [Comandos para resolver]
        ```

        ### Logs de Debug
        ```bash
        # Comandos para habilitar debug logging
        ```

        ## 🧪 Testing

        ### Tests Unitarios
        ```bash
        [Comandos para ejecutar tests]
        ```

        ### Tests de Integración
        ```bash
        [Comandos para tests de integración]
        ```

        ### Tests de Performance
        ```bash
        [Comandos para tests de performance]
        ```

        ## 🤝 Contribución

        ### Workflow de Desarrollo
        1. Fork del repositorio
        2. Crear feature branch
        3. Implementar cambios
        4. Ejecutar tests
        5. Crear Pull Request

        ### Estándares de Código
        - [Estándar 1]: [Descripción]
        - [Estándar 2]: [Descripción]

        ### Code Review Process
        [Proceso específico de revisión]

        ## 📚 Referencias

        ### Documentación Técnica
        - [Link 1]: [Descripción]
        - [Link 2]: [Descripción]

        ### Recursos Adicionales
        - [Recurso 1]: [Descripción]
        - [Recurso 2]: [Descripción]

        ## 📞 Soporte

        ### Contactos
        - **Tech Lead**: [Contacto]
        - **DevOps**: [Contacto]
        - **Product Owner**: [Contacto]

        ### Canales de Comunicación
        - **Slack**: [Canal]
        - **Email**: [Lista]
        - **Issues**: [GitHub/Jira]

        ---

        **Última actualización**: [Fecha]
        **Versión**: [Versión del documento]
        **Mantenido por**: [Equipo responsable]

        Genera documentación completa, práctica y fácil de seguir.
        """
        
        return PromptTemplate(
            input_variables=[
                "code_analysis", "architecture_recommendation", "doc_type",
                "target_audience", "technical_level", "project_name"
            ],
            template=template
        )
    
    @staticmethod
    def get_microservice_analysis_prompt() -> PromptTemplate:
        """Prompt especializado para análisis de microservicios"""
        template = """
        Eres un experto en arquitectura de microservicios con experiencia en sistemas distribuidos.

        **CÓDIGO DEL MICROSERVICIO:**
        ```{language}
        {code_content}
        ```

        **CONTEXTO DEL SISTEMA:**
        {system_context}

        Analiza este microservicio específicamente:

        ## ANÁLISIS DE MICROSERVICIO

        ### 1. Identificación del Dominio
        - **Dominio de Negocio**: [Identificado]
        - **Bounded Context**: [Definición]
        - **Responsabilidades**: [Lista específica]

        ### 2. Interfaces y Contratos
        - **APIs Expuestas**: [Endpoints y contratos]
        - **Eventos Publicados**: [Si aplica]
        - **Dependencias Externas**: [Otros servicios]

        ### 3. Patrones de Microservicios
        - **Database per Service**: [Implementado?]
        - **API Gateway**: [Necesario?]
        - **Circuit Breaker**: [Implementado?]
        - **Saga Pattern**: [Para transacciones distribuidas]

        ### 4. Observabilidad
        - **Logging**: [Estrategia actual]
        - **Métricas**: [Qué se mide]
        - **Tracing**: [Implementado?]
        - **Health Checks**: [Configurados?]

        ### 5. Recomendaciones Específicas
        - [Recomendación específica para microservicios]
        - [Mejora en comunicación entre servicios]
        - [Optimización de performance]

        Enfócate en aspectos específicos de microservicios y sistemas distribuidos.
        """
        
        return PromptTemplate(
            input_variables=["language", "code_content", "system_context"],
            template=template
        )

# Instancia global de prompts
analysis_prompts = AnalysisPrompts()
