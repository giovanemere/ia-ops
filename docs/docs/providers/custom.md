# Providers Personalizados

## 🔧 Creación de Conectores Personalizados

### Interfaz Base del Provider

```typescript
interface IProvider {
  name: string;
  type: string;
  
  // Autenticación
  authenticate(config: ProviderConfig): Promise<boolean>;
  
  // Operaciones CRUD
  createTask(task: TaskDefinition): Promise<ExternalTask>;
  updateTask(id: string, updates: Partial<TaskDefinition>): Promise<ExternalTask>;
  getTask(id: string): Promise<ExternalTask>;
  deleteTask(id: string): Promise<boolean>;
  
  // Metadatos
  getProjectInfo(): Promise<ProjectInfo>;
  getTaskTypes(): Promise<TaskType[]>;
  getFields(): Promise<Field[]>;
  
  // Validación
  validateStructure(structure: TaskStructure): Promise<ValidationResult>;
}
```

### Implementación de Provider Personalizado

```typescript
class CustomProvider implements IProvider {
  name = "Custom API";
  type = "custom";
  
  private config: ProviderConfig;
  private httpClient: HttpClient;
  
  constructor(config: ProviderConfig) {
    this.config = config;
    this.httpClient = new HttpClient(config.baseUrl);
  }
  
  async authenticate(config: ProviderConfig): Promise<boolean> {
    try {
      const response = await this.httpClient.post('/auth', {
        apiKey: config.apiKey,
        secret: config.secret
      });
      
      this.httpClient.setAuthToken(response.data.token);
      return true;
    } catch (error) {
      return false;
    }
  }
  
  async createTask(task: TaskDefinition): Promise<ExternalTask> {
    const payload = this.mapToProviderFormat(task);
    
    const response = await this.httpClient.post('/tasks', payload);
    
    return this.mapFromProviderFormat(response.data);
  }
  
  private mapToProviderFormat(task: TaskDefinition): any {
    return {
      title: task.title,
      description: task.description,
      type: this.mapTaskType(task.type),
      priority: this.mapPriority(task.priority),
      assignee: task.assignee,
      customFields: task.customFields
    };
  }
  
  private mapFromProviderFormat(data: any): ExternalTask {
    return {
      id: data.id,
      externalId: data.external_id,
      title: data.title,
      description: data.description,
      status: data.status,
      url: `${this.config.baseUrl}/tasks/${data.id}`,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at)
    };
  }
}
```

### Configuración del Provider

```yaml
custom_provider:
  name: "Internal Task System"
  type: "custom"
  config:
    base_url: "https://api.internal.company.com"
    api_key: "${INTERNAL_API_KEY}"
    secret: "${INTERNAL_API_SECRET}"
    
  field_mapping:
    title: "summary"
    description: "details"
    priority: "importance"
    assignee: "owner"
    
  task_types:
    - name: "Feature Request"
      external_id: "feature"
    - name: "Bug Report"
      external_id: "bug"
    - name: "Improvement"
      external_id: "enhancement"
      
  priority_mapping:
    high: "critical"
    medium: "normal"
    low: "minor"
```

### Registro del Provider

```typescript
// providers/registry.ts
import { ProviderRegistry } from '../core/ProviderRegistry';
import { CustomProvider } from './CustomProvider';

export function registerCustomProviders() {
  ProviderRegistry.register('custom-internal', CustomProvider);
  ProviderRegistry.register('custom-external', AnotherCustomProvider);
}
```

### Validación y Testing

```typescript
// tests/providers/CustomProvider.test.ts
describe('CustomProvider', () => {
  let provider: CustomProvider;
  
  beforeEach(() => {
    provider = new CustomProvider(mockConfig);
  });
  
  it('should authenticate successfully', async () => {
    const result = await provider.authenticate(mockConfig);
    expect(result).toBe(true);
  });
  
  it('should create task correctly', async () => {
    const task = mockTaskDefinition();
    const result = await provider.createTask(task);
    
    expect(result.id).toBeDefined();
    expect(result.title).toBe(task.title);
  });
});
```

### Webhooks y Sincronización

```typescript
class CustomProviderWithWebhooks extends CustomProvider {
  async setupWebhooks(): Promise<void> {
    await this.httpClient.post('/webhooks', {
      url: `${process.env.WEBHOOK_BASE_URL}/providers/custom/webhook`,
      events: ['task.created', 'task.updated', 'task.deleted']
    });
  }
  
  handleWebhook(payload: any): WebhookEvent {
    return {
      type: payload.event_type,
      taskId: payload.task.id,
      changes: payload.changes,
      timestamp: new Date(payload.timestamp)
    };
  }
}
```
