# Business Ideas Module

## 💡 Gestión de Ideas de Negocio

### Funcionalidades Principales

#### 1. Captura de Ideas
- Formulario inteligente con campos dinámicos
- Categorización automática por tipo
- Evaluación inicial de viabilidad
- Adjuntos y documentación de soporte

#### 2. Evaluación y Priorización
- Criterios configurables de evaluación
- Scoring automático basado en reglas
- Matriz de priorización (impacto vs esfuerzo)
- Recomendaciones de siguiente paso

#### 3. Dashboard de Ideas
- Vista general de todas las ideas
- Filtros por estado, categoría, prioridad
- Métricas de conversión
- Timeline de progreso

### Campos de Captura

```yaml
business_idea:
  title: string (required)
  description: text (required)
  category: enum [feature, improvement, bug_fix, research]
  business_value: enum [high, medium, low]
  complexity: enum [high, medium, low]
  urgency: enum [high, medium, low]
  stakeholders: array[string]
  success_criteria: text
  assumptions: text
  risks: text
  attachments: array[file]
```

### Estados del Ciclo de Vida

1. **Draft**: Idea en borrador
2. **Submitted**: Idea enviada para evaluación
3. **Under Review**: En proceso de evaluación
4. **Approved**: Aprobada para estructuración
5. **In Progress**: En proceso de implementación
6. **Completed**: Implementada exitosamente
7. **Rejected**: Rechazada con justificación
