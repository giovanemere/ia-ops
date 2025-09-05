# Task Structure Management

## 📋 Gestión Dinámica de Estructuras

### Motor de Templates

#### Templates por Área Organizacional

```yaml
templates:
  requirements:
    - type: "Epic"
      title: "[REQ] {idea_title}"
      description: "Requirements analysis for {idea_title}"
      subtasks:
        - type: "Story"
          title: "Gather business requirements"
        - type: "Story"
          title: "Define acceptance criteria"
          
  architecture:
    - type: "Epic"
      title: "[ARCH] {idea_title}"
      description: "Architecture design for {idea_title}"
      subtasks:
        - type: "Task"
          title: "Create technical design"
        - type: "Task"
          title: "Architecture decision records"
          
  development:
    - type: "Epic"
      title: "[DEV] {idea_title}"
      description: "Development implementation for {idea_title}"
      subtasks:
        - type: "Story"
          title: "Implement core functionality"
        - type: "Task"
          title: "Unit tests"
        - type: "Task"
          title: "Code review"
```

### Mapeo de Campos

#### Jira Mapping
```yaml
field_mapping:
  jira:
    title: "summary"
    description: "description"
    priority: "priority"
    assignee: "assignee"
    labels: "labels"
    business_value: "customfield_10001"
```

#### Azure DevOps Mapping
```yaml
field_mapping:
  azure:
    title: "System.Title"
    description: "System.Description"
    priority: "Microsoft.VSTS.Common.Priority"
    assignee: "System.AssignedTo"
    tags: "System.Tags"
```

### Validación de Estructura

- Campos obligatorios por tipo de tarea
- Validación de dependencias
- Verificación de permisos
- Consistencia de datos
