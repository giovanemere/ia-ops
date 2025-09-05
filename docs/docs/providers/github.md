# Integración con GitHub

## 🔗 Configuración de GitHub

### Autenticación

#### GitHub Token
```bash
# Variables de entorno
GITHUB_TOKEN=ghp_your_token_here
GITHUB_OWNER=organization
GITHUB_REPO=repository
```

#### GitHub App (Recomendado para organizaciones)
```yaml
github_app:
  app_id: "123456"
  private_key_path: "/path/to/private-key.pem"
  installation_id: "789012"
```

### Configuración de Repositorio

```yaml
github_config:
  owner: "organization"
  repo: "repository"
  
  labels:
    - name: "enhancement"
      color: "a2eeef"
    - name: "bug"
      color: "d73a4a"
    - name: "documentation"
      color: "0075ca"
    - name: "priority:high"
      color: "ff0000"
      
  milestones:
    - title: "Sprint 1"
      description: "First sprint deliverables"
      due_date: "2024-02-01"
      
  projects:
    - name: "Development Board"
      number: 1
      columns: ["To Do", "In Progress", "Review", "Done"]
```

### Mapeo de Entidades

#### Issues
| IA-Ops Field | GitHub Field | Tipo |
|--------------|--------------|------|
| title | title | string |
| description | body | markdown |
| assignees | assignees | array |
| labels | labels | array |
| milestone | milestone | object |

#### Projects v2
```yaml
project_fields:
  status:
    type: "single_select"
    options: ["Todo", "In Progress", "Done"]
    
  priority:
    type: "single_select"
    options: ["High", "Medium", "Low"]
    
  story_points:
    type: "number"
    
  area:
    type: "single_select"
    options: ["Frontend", "Backend", "DevOps"]
```

### Ejemplos de Uso

#### Crear Issue
```javascript
const issue = {
  title: "Implement user authentication",
  body: `## Description
User authentication system with secure login

## Acceptance Criteria
- [ ] User can login with email/password
- [ ] Password validation
- [ ] Session management`,
  labels: ["enhancement", "priority:high"],
  assignees: ["developer1"],
  milestone: 1
};
```

#### Crear Issue con Project
```javascript
const issueWithProject = {
  title: "Fix login bug",
  body: "Users cannot login after password reset",
  labels: ["bug", "priority:high"],
  project: {
    number: 1,
    fields: {
      "Status": "Todo",
      "Priority": "High",
      "Story Points": 3
    }
  }
};
```

#### Crear Milestone
```javascript
const milestone = {
  title: "v1.0.0 Release",
  description: "First major release",
  due_on: "2024-03-01T00:00:00Z",
  state: "open"
};
```
