# Business Ideas API

## 💡 API de Gestión de Ideas

### Endpoints Principales

#### Crear Idea
```http
POST /api/v1/business-ideas
Content-Type: application/json

{
  "title": "Sistema de Autenticación Mejorado",
  "description": "Implementar autenticación multifactor para mayor seguridad",
  "category": "feature",
  "business_value": "high",
  "complexity": "medium",
  "urgency": "high",
  "stakeholders": ["security-team", "product-owner"],
  "success_criteria": "Reducir incidentes de seguridad en 80%",
  "assumptions": "Los usuarios aceptarán el proceso adicional",
  "risks": "Posible resistencia al cambio"
}
```

#### Listar Ideas
```http
GET /api/v1/business-ideas?status=submitted&category=feature&page=1&limit=10

Response:
{
  "data": [
    {
      "id": "uuid",
      "title": "Sistema de Autenticación Mejorado",
      "status": "submitted",
      "category": "feature",
      "priority_score": 85,
      "created_at": "2024-01-01T10:00:00Z",
      "updated_at": "2024-01-01T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "pages": 3
  }
}
```

#### Obtener Idea
```http
GET /api/v1/business-ideas/{id}

Response:
{
  "id": "uuid",
  "title": "Sistema de Autenticación Mejorado",
  "description": "Implementar autenticación multifactor...",
  "category": "feature",
  "business_value": "high",
  "complexity": "medium",
  "urgency": "high",
  "status": "submitted",
  "priority_score": 85,
  "evaluation": {
    "viability": "high",
    "impact": "high",
    "effort": "medium",
    "risk": "low"
  },
  "stakeholders": ["security-team", "product-owner"],
  "created_by": "user-uuid",
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-01T10:00:00Z"
}
```

#### Actualizar Idea
```http
PUT /api/v1/business-ideas/{id}
Content-Type: application/json

{
  "title": "Sistema de Autenticación Mejorado v2",
  "business_value": "critical",
  "status": "approved"
}
```

#### Evaluar Idea
```http
POST /api/v1/business-ideas/{id}/evaluate

Response:
{
  "priority_score": 85,
  "evaluation": {
    "viability": "high",
    "impact": "high", 
    "effort": "medium",
    "risk": "low"
  },
  "recommendations": [
    "Proceder con análisis de requerimientos",
    "Involucrar al equipo de seguridad desde el inicio"
  ]
}
```

### Modelos de Datos

#### BusinessIdea
```typescript
interface BusinessIdea {
  id: string;
  title: string;
  description: string;
  category: 'feature' | 'improvement' | 'bug_fix' | 'research';
  business_value: 'critical' | 'high' | 'medium' | 'low';
  complexity: 'high' | 'medium' | 'low';
  urgency: 'high' | 'medium' | 'low';
  status: IdeaStatus;
  priority_score: number;
  evaluation?: IdeaEvaluation;
  stakeholders: string[];
  success_criteria?: string;
  assumptions?: string;
  risks?: string;
  attachments?: Attachment[];
  created_by: string;
  created_at: Date;
  updated_at: Date;
}
```

#### IdeaEvaluation
```typescript
interface IdeaEvaluation {
  viability: 'high' | 'medium' | 'low';
  impact: 'high' | 'medium' | 'low';
  effort: 'high' | 'medium' | 'low';
  risk: 'high' | 'medium' | 'low';
  score_breakdown: {
    business_value: number;
    technical_feasibility: number;
    resource_availability: number;
    strategic_alignment: number;
  };
  recommendations: string[];
}
```
