# Integración con Jira

## 🔗 Configuración de Jira

### Autenticación

#### API Token (Recomendado)
```bash
# Variables de entorno
JIRA_BASE_URL=https://company.atlassian.net
JIRA_EMAIL=user@company.com
JIRA_API_TOKEN=your_api_token_here
```

#### OAuth 2.0
```yaml
jira_oauth:
  client_id: "your_client_id"
  client_secret: "your_client_secret"
  redirect_uri: "http://localhost:3000/auth/jira/callback"
```

### Configuración de Proyecto

```yaml
jira_config:
  project_key: "PROJ"
  issue_types:
    - name: "Epic"
      id: "10000"
    - name: "Story"
      id: "10001"
    - name: "Task"
      id: "10002"
    - name: "Bug"
      id: "10003"
      
  custom_fields:
    business_value: "customfield_10001"
    story_points: "customfield_10002"
    team: "customfield_10003"
    
  workflows:
    story: ["To Do", "In Progress", "Code Review", "Testing", "Done"]
    task: ["To Do", "In Progress", "Done"]
```

### Mapeo de Campos

#### Campos Estándar
| IA-Ops Field | Jira Field | Tipo |
|--------------|------------|------|
| title | summary | string |
| description | description | text |
| priority | priority | select |
| assignee | assignee | user |
| labels | labels | array |

#### Campos Personalizados
```yaml
custom_field_mapping:
  business_value:
    jira_field: "customfield_10001"
    type: "select"
    options: ["High", "Medium", "Low"]
    
  story_points:
    jira_field: "customfield_10002"
    type: "number"
    
  acceptance_criteria:
    jira_field: "customfield_10003"
    type: "text"
```

### Ejemplos de Uso

#### Crear Epic
```javascript
const epic = {
  title: "User Authentication System",
  description: "Implement secure user authentication",
  issueType: "Epic",
  priority: "High",
  labels: ["security", "authentication"]
};
```

#### Crear Story con Subtasks
```javascript
const story = {
  title: "Login page implementation",
  description: "Create login form with validation",
  issueType: "Story",
  parent: "PROJ-100", // Epic
  subtasks: [
    {
      title: "Design login form UI",
      issueType: "Task",
      assignee: "designer@company.com"
    },
    {
      title: "Implement form validation",
      issueType: "Task",
      assignee: "developer@company.com"
    }
  ]
};
```
