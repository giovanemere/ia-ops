# Provider Connectors

## 🔗 Integración con Sistemas Externos

### Providers Soportados

#### Jira
- **Entidades**: Issues, Epics, Stories, Tasks, Bugs
- **Campos**: Summary, Description, Priority, Assignee, Labels
- **Workflows**: Configurables por proyecto
- **Autenticación**: API Token, OAuth 2.0

#### Azure DevOps
- **Entidades**: Work Items, Features, User Stories, Tasks
- **Campos**: Title, Description, State, Assigned To, Tags
- **Boards**: Kanban y Scrum
- **Autenticación**: Personal Access Token

#### GitHub
- **Entidades**: Issues, Projects, Milestones
- **Campos**: Title, Body, Labels, Assignees
- **Projects**: GitHub Projects v2
- **Autenticación**: GitHub Token, GitHub App

### Configuración de Providers

```yaml
provider_config:
  jira:
    base_url: "https://company.atlassian.net"
    project_key: "PROJ"
    issue_types: ["Story", "Task", "Bug"]
    custom_fields:
      business_value: "customfield_10001"
      
  azure:
    organization: "company"
    project: "ProjectName"
    work_item_types: ["Feature", "User Story", "Task"]
    
  github:
    owner: "organization"
    repo: "repository"
    project_number: 1
```
