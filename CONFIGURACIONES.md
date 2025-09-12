# 📊 TABLA DE CONFIGURACIONES CENTRALIZADAS - IA-Ops Portal

## 🗂️ **ALMACENAMIENTO UNIFICADO**

Todas las configuraciones se almacenan en **localStorage** del navegador como fuente única de verdad:

### **🔗 PROVIDERS (Cloud & DevOps)**
| Provider | LocalStorage Key | Campos | Ubicación UI |
|----------|------------------|--------|--------------|
| **GitHub** | `githubConfig` | `token`, `user` | Settings > Providers > GitHub |
| **Azure** | `azureConfig` | `subscription_id`, `tenant_id`, `client_id`, `client_secret` | Settings > Providers > Azure |
| **AWS** | `awsConfig` | `access_key`, `secret_key`, `region` | Settings > Providers > AWS |
| **GCP** | `gcpConfig` | `project_id`, `service_account_key` | Settings > Providers > GCP |
| **OCI** | `ociConfig` | `tenancy`, `user`, `fingerprint`, `key_file` | Settings > Providers > OCI |

### **🤖 API PROVIDERS (IA & ML)**
| Provider | LocalStorage Key | Campos | Ubicación UI |
|----------|------------------|--------|--------------|
| **OpenAI** | `openaiConfig` | `apiKey`, `organization`, `model`, `maxTokens` | Settings > API Providers > OpenAI |
| **Google AI** | `googleAIConfig` | `apiKey`, `model` | Settings > API Providers > Google AI |
| **AWS Bedrock** | `bedrockConfig` | `accessKey`, `secretKey`, `region`, `model` | Settings > API Providers > AWS Bedrock |
| **Anthropic** | `anthropicConfig` | `apiKey`, `model` | Settings > API Providers > Anthropic |
| **Azure AI** | `azureAIConfig` | `apiKey`, `endpoint`, `deployment`, `version` | Settings > API Providers > Azure AI |

### **🛡️ AUTENTICACIÓN**
| Configuración | LocalStorage Key | Campos | Ubicación UI |
|---------------|------------------|--------|--------------|
| **Token Actual** | `authToken` | Bearer token (SHA256) | Settings > Autenticación > Token Actual |
| **Expiración** | `tokenExpiry` | Timestamp de expiración | Settings > Autenticación > Token Actual |
| **Backend URL** | `backendUrl` | URL del backend | Settings > Autenticación > Config Manual |

### **🖥️ SISTEMA (Infraestructura)**
| Servicio | LocalStorage Key | Campos | Ubicación UI |
|----------|------------------|--------|--------------|
| **PostgreSQL** | `postgresConfig` | `host`, `port`, `database`, `user`, `password` | Settings > Sistema > PostgreSQL |
| **Redis** | `redisConfig` | `host`, `port`, `password`, `database` | Settings > Sistema > Redis |
| **MinIO** | `minioConfig` | `host`, `port`, `accessKey`, `secretKey`, `bucket`, `region`, `ssl` | Settings > Sistema > MinIO |

## 🔄 **FLUJO DE CONFIGURACIÓN UNIFICADO**

### **1. Configuración Centralizada**
```
Settings (http://localhost:8845/settings)
├── Providers (Cloud/DevOps)
├── API Providers (IA/ML) 
├── Autenticación (Tokens)
└── Sistema (Infraestructura)
```

### **2. Consumo en Otras Páginas**
```
Repositorios (http://localhost:8845/repositories)
├── Usa: githubConfig (desde Settings)
├── Botón: "Cargar desde GitHub"
└── NO tiene configuración duplicada
```

### **3. Persistencia**
```javascript
// Guardar configuración
localStorage.setItem('githubConfig', JSON.stringify(config));

// Cargar configuración
const config = JSON.parse(localStorage.getItem('githubConfig') || '{}');

// Verificar configuración
if (config.token) { /* configurado */ }
```

## 🎯 **BENEFICIOS DE LA CENTRALIZACIÓN**

### ✅ **Ventajas Implementadas:**
- **Fuente única de verdad**: Todas las configs en Settings
- **No duplicación**: Eliminada config duplicada en repositorios
- **Consistencia**: Mismo formato en todas las páginas
- **Seguridad**: Tokens enmascarados después de guardar
- **Validación**: Campos requeridos validados
- **Feedback**: Estados visuales en tiempo real

### 🔧 **Funciones Comunes:**
```javascript
// Cargar todas las configuraciones
loadAllConfigurations()

// Guardar configuración específica
saveGitHubConfig()
saveOpenAIConfig()
savePostgresConfig()

// Probar conexiones
testGitHubConnection()
testOpenAIConnection()
testDatabaseConnection()

// Actualizar estados visuales
updateGitHubStatus(configured)
updateOpenAIStatus(configured)
updateDatabaseStatus(status)
```

## 📱 **INTERFAZ UNIFICADA**

### **Navegación por Tabs:**
```
┌─ Providers ─┐┌─ API Providers ─┐┌─ Autenticación ─┐┌─ Sistema ─┐
│ GitHub      ││ OpenAI          ││ Token Actual    ││ PostgreSQL │
│ Azure       ││ Google AI       ││ Config Manual   ││ Redis      │
│ AWS         ││ AWS Bedrock     ││                 ││ MinIO      │
│ GCP         ││ Anthropic       ││                 ││            │
│ OCI         ││ Azure AI        ││                 ││            │
└─────────────┘└─────────────────┘└─────────────────┘└────────────┘
```

### **Botones Estándar:**
- 💾 **Guardar**: Persiste configuración
- 🔌 **Probar Conexión**: Valida configuración
- 🔄 **Actualizar**: Recarga estado

## 🌐 **URLs DE CONFIGURACIÓN**

| Sección | URL | Propósito |
|---------|-----|-----------|
| **Settings Principal** | `http://localhost:8845/settings` | Configuración centralizada |
| **Repositorios** | `http://localhost:8845/repositories` | Consume config GitHub |
| **Backend API** | `http://localhost:8846/api/*` | APIs protegidas con auth |

## 🔒 **SEGURIDAD**

### **Tokens y Secrets:**
- ✅ Campos `type="password"` por defecto
- ✅ Toggle show/hide con iconos
- ✅ Enmascarado después de guardar
- ✅ No se muestran en placeholders
- ✅ Validación antes de usar

### **Autenticación Backend:**
- ✅ Bearer tokens para APIs
- ✅ Re-autenticación automática
- ✅ Expiración controlada
- ✅ API keys centralizadas

**¡CONFIGURACIÓN COMPLETAMENTE CENTRALIZADA Y UNIFICADA!** 🚀
