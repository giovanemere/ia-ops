# Integración con Azure DevOps

## 🔗 Configuración de Azure DevOps

### Autenticación

#### Personal Access Token (PAT)
```bash
# Variables de entorno
AZURE_ORGANIZATION=company
AZURE_PROJECT=ProjectName
AZURE_PAT=your_personal_access_token
```

### Configuración de Proyecto

```yaml
azure_config:
  organization: "company"
  project: "ProjectName"
  
  work_item_types:
    - name: "Feature"
      id: "Microsoft.VSTS.WorkItemTypes.Feature"
    - name: "User Story"
      id: "Microsoft.VSTS.WorkItemTypes.UserStory"
    - name: "Task"
      id: "Microsoft.VSTS.WorkItemTypes.Task"
    - name: "Bug"
      id: "Microsoft.VSTS.WorkItemTypes.Bug"
      
  areas:
    - "ProjectName\\Requirements"
    - "ProjectName\\Architecture"
    - "ProjectName\\Development"
    
  iterations:
    - "ProjectName\\Sprint 1"
    - "ProjectName\\Sprint 2"
```

### Mapeo de Campos

#### Campos del Sistema
| IA-Ops Field | Azure Field | Tipo |
|--------------|-------------|------|
| title | System.Title | string |
| description | System.Description | html |
| state | System.State | string |
| assignee | System.AssignedTo | identity |
| tags | System.Tags | string |

#### Campos Personalizados
```yaml
field_mapping:
  priority: "Microsoft.VSTS.Common.Priority"
  story_points: "Microsoft.VSTS.Scheduling.StoryPoints"
  business_value: "Microsoft.VSTS.Common.BusinessValue"
  acceptance_criteria: "Microsoft.VSTS.Common.AcceptanceCriteria"
  area_path: "System.AreaPath"
  iteration_path: "System.IterationPath"
```

### Estados de Work Items

#### User Story States
- New
- Active
- Resolved
- Closed
- Removed

#### Task States
- New
- Active
- Closed
- Removed

### Ejemplos de Uso

#### Crear Feature
```javascript
const feature = {
  title: "User Management System",
  description: "<p>Comprehensive user management functionality</p>",
  workItemType: "Feature",
  fields: {
    "Microsoft.VSTS.Common.Priority": 1,
    "System.AreaPath": "ProjectName\\Requirements"
  }
};
```

#### Crear User Story con Tasks
```javascript
const userStory = {
  title: "As a user, I want to login securely",
  description: "<p>User authentication with secure login</p>",
  workItemType: "User Story",
  parent: 100, // Feature ID
  fields: {
    "Microsoft.VSTS.Scheduling.StoryPoints": 5,
    "Microsoft.VSTS.Common.AcceptanceCriteria": "User can login with email and password"
  },
  children: [
    {
      title: "Create login API endpoint",
      workItemType: "Task",
      fields: {
        "System.AssignedTo": "developer@company.com"
      }
    }
  ]
};
```
