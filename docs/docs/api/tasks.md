# Tasks API

## 📋 API de Gestión de Tareas

### Endpoints

#### Crear Estructura de Tareas
```http
POST /api/v1/task-structures
Content-Type: application/json

{
  "idea_id": "uuid",
  "provider_id": "uuid",
  "organizational_areas": ["requirements", "development", "testing"],
  "custom_structure": {
    "epic": {
      "title": "User Authentication System",
      "description": "Implement secure user authentication"
    }
  }
}
```

#### Generar Estructura Automática
```http
POST /api/v1/task-structures/generate
Content-Type: application/json

{
  "idea_id": "uuid",
  "provider_type": "jira",
  "areas": ["requirements", "architecture", "development"]
}

Response:
{
  "structure": {
    "epic": {
      "title": "[REQ] User Authentication Analysis",
      "subtasks": [
        {
          "type": "story",
          "title": "Gather authentication requirements"
        }
      ]
    }
  },
  "preview_url": "/preview/uuid"
}
```

#### Enviar a Refinamiento
```http
POST /api/v1/task-structures/{id}/refine

Response:
{
  "refinement_session_id": "uuid",
  "workspace_url": "/refinement/uuid"
}
```
