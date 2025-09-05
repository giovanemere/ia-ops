# Flujo de Datos

## 🔄 Flujo Principal de Datos

### 1. Captura de Ideas
```
Usuario → IdeaCapture → Database → IdeaEvaluator → Categorización
```

### 2. Estructuración
```
Idea → TemplateEngine → ProviderConnector → StructureMapper → Preview
```

### 3. Refinamiento
```
Structure → VisualEditor → CommentSystem → ApprovalWorkflow → FinalStructure
```

### 4. Creación
```
ApprovedStructure → SubmissionQueue → TaskCreator → ExternalProvider → Confirmation
```

## 📊 Modelo de Datos

### Entidades Principales
- **BusinessIdea**: Ideas de negocio
- **Provider**: Configuración de providers
- **TaskStructure**: Estructuras de tareas
- **RefinementSession**: Sesiones de refinamiento
- **AuditLog**: Logs de auditoría
