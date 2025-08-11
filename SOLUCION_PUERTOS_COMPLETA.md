# 🚀 IA-Ops Platform - Solución Completa de Puertos

## 📋 Resumen de la Solución

Se ha resuelto exitosamente el problema de conflictos de puertos y el error "Failed to fetch" en Backstage. La solución implementa una arquitectura híbrida donde:

- **Backstage corre en el host** (puertos 3002 y 7007)
- **Servicios de soporte corren en Docker** (PostgreSQL, Redis, OpenAI Service)
- **Servicios adicionales disponibles** (Grafana, Prometheus, MkDocs)

## ✅ Problemas Resueltos

1. **❌ Error "Failed to fetch"** → ✅ **Resuelto**: Backstage frontend y backend comunicándose correctamente
2. **❌ Conflictos de puertos** → ✅ **Resuelto**: Configuración de puertos sin solapamiento
3. **❌ Errores de YAML** → ✅ **Resuelto**: Configuración YAML corregida y validada
4. **❌ Problemas de Docker build** → ✅ **Resuelto**: Backstage ejecutándose directamente en host

## 🔧 Configuración Final de Puertos

| Puerto | Servicio | Estado | Ubicación | URL |
|--------|----------|--------|-----------|-----|
| **3002** | Backstage Frontend | ✅ Activo | Host | http://localhost:3002 |
| **7007** | Backstage Backend | ✅ Activo | Host | http://localhost:7007 |
| **5432** | PostgreSQL | ✅ Activo | Docker | localhost:5432 |
| **6379** | Redis | ✅ Activo | Docker | localhost:6379 |
| **8003** | OpenAI Service | ✅ Activo | Docker | http://localhost:8003 |
| **8004** | OpenAI Metrics | ✅ Activo | Docker | http://localhost:8004 |
| **3001** | Grafana | 🟡 Disponible | Docker | http://localhost:3001 |
| **9090** | Prometheus | 🟡 Disponible | Docker | http://localhost:9090 |
| **8005** | MkDocs | 🟡 Disponible | Docker | http://localhost:8005 |
| **8006** | TechDocs | 🟡 Disponible | Docker | http://localhost:8006 |
| **9100** | Node Exporter | 🟡 Disponible | Docker | http://localhost:9100 |
| **8082** | cAdvisor | 🟡 Disponible | Docker | http://localhost:8082 |

## 🚀 Uso Rápido

### Iniciar Todo el Sistema
```bash
cd /home/giovanemere/ia-ops/ia-ops
./start-ia-ops-complete.sh
```

### Detener Todo el Sistema
```bash
cd /home/giovanemere/ia-ops/ia-ops
./stop-ia-ops-complete.sh
```

### Verificar Estado
```bash
# Ver servicios Docker
docker-compose ps

# Ver puertos activos
netstat -tlnp | grep -E ':(3002|7007|5432|6379|8003)'

# Probar API de Backstage
curl http://localhost:7007/api/catalog/health
```

## 🔍 Comandos Específicos

### Solo Servicios Básicos
```bash
# Iniciar servicios de soporte
docker-compose up -d postgres redis openai-service

# Iniciar Backstage
cd applications/backstage
./kill-ports.sh && ./sync-env-config.sh && ./start-robust.sh
```

### Servicios Adicionales
```bash
# Agregar monitoreo y documentación
docker-compose up -d grafana prometheus mkdocs node-exporter cadvisor
```

## 📊 Verificación de Funcionamiento

### 1. Verificar Backstage
```bash
# Frontend
curl -I http://localhost:3002

# Backend API
curl http://localhost:7007/api/catalog/entities
```

### 2. Verificar Servicios Docker
```bash
# Estado de contenedores
docker-compose ps

# Logs de servicios
docker-compose logs openai-service
docker-compose logs postgres
docker-compose logs redis
```

### 3. Verificar Conectividad
```bash
# Desde Backstage a PostgreSQL
# (Se verifica automáticamente en los logs de Backstage)

# OpenAI Service
curl http://localhost:8003/health
```

## 🛠️ Solución de Problemas

### Error "Failed to fetch"
```bash
# 1. Verificar que ambos servicios estén corriendo
netstat -tlnp | grep -E ':(3002|7007)'

# 2. Reiniciar Backstage si es necesario
cd applications/backstage
./kill-ports.sh
./start-robust.sh
```

### Conflictos de Puertos
```bash
# Liberar puertos específicos
fuser -k 3002/tcp 7007/tcp

# O usar el script de Backstage
cd applications/backstage
./kill-ports.sh
```

### Problemas de Docker
```bash
# Reiniciar servicios Docker
docker-compose restart postgres redis openai-service

# Ver logs detallados
docker-compose logs -f [servicio]
```

## 📝 Archivos Importantes

### Scripts de Gestión
- `start-ia-ops-complete.sh` - Inicia toda la plataforma
- `stop-ia-ops-complete.sh` - Detiene toda la plataforma
- `applications/backstage/kill-ports.sh` - Libera puertos de Backstage
- `applications/backstage/start-robust.sh` - Inicia Backstage de forma robusta

### Configuración
- `docker-compose.yml` - Configuración de servicios Docker
- `.env` - Variables de entorno
- `applications/backstage/app-config.yaml` - Configuración de Backstage (corregida)
- `PUERTOS_CONFIGURACION.md` - Documentación detallada de puertos

### Logs
- `applications/backstage/backstage-production.log` - Logs de Backstage en producción
- `docker-compose logs` - Logs de servicios Docker

## 🎯 Próximos Pasos

1. **✅ Completado**: Resolver conflictos de puertos
2. **✅ Completado**: Corregir configuración YAML
3. **✅ Completado**: Establecer comunicación frontend-backend
4. **🔄 En progreso**: Optimizar integración con Docker
5. **📋 Pendiente**: Implementar GitHub Discovery processor
6. **📋 Pendiente**: Configurar proxy service para unificar acceso

## 🏆 Resultado Final

La plataforma IA-Ops está ahora **completamente funcional** con:

- ✅ **Backstage Portal** funcionando en http://localhost:3002
- ✅ **API de Backstage** respondiendo en http://localhost:7007
- ✅ **Servicios de IA** activos en http://localhost:8003
- ✅ **Base de datos** y **cache** funcionando correctamente
- ✅ **Sin conflictos de puertos**
- ✅ **Configuración estable y reproducible**

**¡El error "Failed to fetch" ha sido completamente resuelto!** 🎉
