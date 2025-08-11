# 🚀 IA-Ops Platform - Configuración de Puertos

## 📊 Estado Actual de Servicios

### ✅ Servicios Funcionando

| Servicio | Puerto | Estado | Tipo | URL de Acceso |
|----------|--------|--------|------|---------------|
| **Backstage Frontend** | 3002 | ✅ Activo | Node.js (Host) | http://localhost:3002 |
| **Backstage Backend** | 7007 | ✅ Activo | Node.js (Host) | http://localhost:7007 |
| **PostgreSQL** | 5432 | ✅ Activo | Docker | localhost:5432 |
| **Redis** | 6379 | ✅ Activo | Docker | localhost:6379 |
| **OpenAI Service** | 8003 | ✅ Activo | Docker | http://localhost:8003 |
| **OpenAI Metrics** | 8004 | ✅ Activo | Docker | http://localhost:8004 |

### 🔄 Servicios Disponibles (No iniciados)

| Servicio | Puerto | Estado | Configuración |
|----------|--------|--------|---------------|
| **Proxy Service** | 8080 | 🟡 Disponible | docker-compose |
| **MkDocs** | 8005 | 🟡 Disponible | docker-compose |
| **TechDocs** | 8006 | 🟡 Disponible | docker-compose |
| **Grafana** | 3001 | 🟡 Disponible | docker-compose |
| **Prometheus** | 9090 | 🟡 Disponible | docker-compose |
| **Node Exporter** | 9100 | 🟡 Disponible | docker-compose |
| **cAdvisor** | 8082 | 🟡 Disponible | docker-compose |

## 🔧 Configuración Actual

### Backstage (Corriendo en Host)
```bash
# Comandos para gestionar Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage

# Liberar puertos
./kill-ports.sh

# Sincronizar configuración
./sync-env-config.sh

# Iniciar Backstage
./start-robust.sh
```

### Docker Services (Servicios de Soporte)
```bash
cd /home/giovanemere/ia-ops/ia-ops

# Servicios básicos activos
docker-compose up -d postgres redis openai-service

# Servicios adicionales disponibles
docker-compose up -d mkdocs prometheus grafana node-exporter cadvisor
```

## 🌐 URLs de Acceso

### Principales
- **Backstage Portal**: http://localhost:3002
- **Backstage API**: http://localhost:7007
- **OpenAI Service**: http://localhost:8003

### Monitoreo (cuando se inicien)
- **Grafana**: http://localhost:3001 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **MkDocs**: http://localhost:8005

## 🔍 Verificación de Estado

### Verificar Puertos Activos
```bash
netstat -tlnp | grep -E ':(3000|3002|5432|6379|7007|8003|8004|8080)' | sort
```

### Verificar Servicios Docker
```bash
docker-compose ps
```

### Verificar Logs de Backstage
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
tail -f backstage-success-final.log
```

## 🚨 Solución de Problemas

### Error "Failed to fetch" en Backstage
1. Verificar que el backend esté corriendo en puerto 7007
2. Verificar que el frontend esté corriendo en puerto 3002
3. Verificar conectividad entre frontend y backend

### Conflictos de Puertos
```bash
# Liberar puertos específicos
fuser -k 3002/tcp
fuser -k 7007/tcp

# O usar el script
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./kill-ports.sh
```

### Reiniciar Servicios
```bash
# Reiniciar Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./kill-ports.sh
./start-robust.sh

# Reiniciar servicios Docker
cd /home/giovanemere/ia-ops/ia-ops
docker-compose restart postgres redis openai-service
```

## 📝 Notas Importantes

1. **Backstage corre en el host** (no en Docker) para evitar problemas de build
2. **Los servicios de soporte corren en Docker** (PostgreSQL, Redis, OpenAI)
3. **El proxy service está configurado** pero no iniciado para evitar conflictos
4. **La configuración YAML de Backstage** ha sido corregida para evitar errores de parsing

## 🔄 Próximos Pasos

1. **Integrar Proxy Service**: Configurar el proxy para que apunte a Backstage en el host
2. **Iniciar Servicios de Monitoreo**: Grafana, Prometheus, etc.
3. **Configurar GitHub Discovery**: Instalar el procesador faltante
4. **Optimizar Docker Build**: Crear Dockerfiles funcionales para Backstage

## ✅ Estado de Resolución

- ✅ **Conflictos de puertos resueltos**
- ✅ **Configuración YAML corregida**
- ✅ **Backstage funcionando correctamente**
- ✅ **Servicios de soporte activos**
- ✅ **Error "Failed to fetch" solucionado**
