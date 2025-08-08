# 🌐 Configuración Consolidada de Puertos - IA-Ops Platform

**Fecha**: 8 de Agosto de 2025  
**Versión**: 2.0.0  
**Estado**: ✅ **CONSOLIDADO**

---

## 📋 **RESUMEN EJECUTIVO**

La plataforma IA-Ops ha sido consolidada en un solo archivo `docker-compose.yml` con todas las configuraciones de puertos centralizadas en el archivo `.env`. Esta configuración permite un despliegue completo y escalable de todos los servicios.

---

## 🗺️ **MAPA COMPLETO DE PUERTOS**

### **🌐 ACCESO PRINCIPAL (Recomendado)**
```bash
# Gateway Principal - Punto de entrada único
http://localhost:8080          # Proxy Service (Gateway)
├── /                         # Backstage Frontend
├── /api/*                    # Backstage Backend
├── /openai/*                 # OpenAI Service
├── /docs/*                   # MkDocs Documentation
├── /grafana/*                # Grafana Dashboards
└── /prometheus/*             # Prometheus Metrics
```

### **🔧 ACCESO DIRECTO A SERVICIOS**
```bash
# Servicios Principales
http://localhost:7007         # Backstage Backend (API)
http://localhost:3002         # Backstage Frontend (UI)
http://localhost:8003         # OpenAI Service (API)
http://localhost:8004         # OpenAI Metrics
http://localhost:8005         # MkDocs Documentation
http://localhost:8006         # TechDocs Builder

# Monitoreo
http://localhost:9090         # Prometheus
http://localhost:3001         # Grafana
http://localhost:9100         # Node Exporter
http://localhost:8082         # cAdvisor

# Bases de Datos
localhost:5432                # PostgreSQL
localhost:6379                # Redis

# Servicios Adicionales
http://localhost:8081         # Nginx Proxy (opcional)
```

---

## ⚙️ **CONFIGURACIÓN DE VARIABLES DE ENTORNO**

### **Variables de Puerto en .env**
```bash
# =============================================================================
# CONFIGURACIÓN DE PUERTOS - MAPA COMPLETO DE LA SOLUCIÓN
# =============================================================================

# 🌐 PROXY SERVICE (Gateway Principal)
PROXY_PORT=8080
PROXY_HOST=0.0.0.0

# 🏛️ BACKSTAGE SERVICES
BACKSTAGE_BACKEND_PORT=7007
BACKSTAGE_FRONTEND_PORT=3002

# 🤖 OPENAI SERVICE
OPENAI_SERVICE_PORT=8003
OPENAI_METRICS_PORT=8004

# 📚 DOCUMENTATION SERVICES
MKDOCS_PORT=8005
TECHDOCS_PORT=8006

# 💾 DATABASE SERVICES
POSTGRES_PORT=5432
REDIS_PORT=6379

# 📊 MONITORING SERVICES
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
NODE_EXPORTER_PORT=9100
CADVISOR_PORT=8082

# 🔧 ADDITIONAL SERVICES
NGINX_PROXY_PORT=8081
```

---

## 🏗️ **ARQUITECTURA DE SERVICIOS**

### **Diagrama de Conectividad**
```
                    ┌─────────────────┐
                    │  Proxy Service  │ :8080
                    │   (Gateway)     │
                    └─────────┬───────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Backstage Front │    │ Backstage Back  │    │  OpenAI Service │
│   :3002         │    │   :7007         │    │   :8003         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │     Redis       │    │   Monitoring    │
│   :5432         │    │    :6379        │    │ :9090/:3001     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🚀 **COMANDOS DE DESPLIEGUE**

### **Inicio Completo**
```bash
# Iniciar todos los servicios
docker-compose up -d

# Verificar estado
docker-compose ps

# Ver logs
docker-compose logs -f
```

### **Inicio Selectivo**
```bash
# Solo bases de datos
docker-compose up -d postgres redis

# Solo servicios principales
docker-compose up -d backstage-backend backstage-frontend openai-service

# Solo monitoreo
docker-compose up -d prometheus grafana

# Incluir Nginx (opcional)
docker-compose --profile nginx up -d
```

### **Health Checks**
```bash
# Gateway principal
curl http://localhost:8080/health

# Servicios individuales
curl http://localhost:8003/health                    # OpenAI Service
curl http://localhost:7007/api/catalog/health        # Backstage Backend
curl http://localhost:9090/-/healthy                 # Prometheus
curl http://localhost:3001/api/health                # Grafana
```

---

## 🔧 **CONFIGURACIÓN AVANZADA**

### **Personalización de Puertos**
Para cambiar puertos, edita el archivo `.env`:

```bash
# Ejemplo: Cambiar puerto del gateway
PROXY_PORT=9080

# Ejemplo: Cambiar puerto de Backstage Frontend
BACKSTAGE_FRONTEND_PORT=4000

# Reiniciar servicios
docker-compose down
docker-compose up -d
```

### **Configuración de Red**
```yaml
# Red personalizada en docker-compose.yml
networks:
  ia-ops-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
```

---

## 📊 **MONITOREO Y MÉTRICAS**

### **Endpoints de Métricas**
```bash
# Prometheus metrics
http://localhost:9090/metrics

# OpenAI Service metrics
http://localhost:8004/metrics

# Node Exporter metrics
http://localhost:9100/metrics

# cAdvisor metrics
http://localhost:8082/metrics
```

### **Dashboards Grafana**
```bash
# Acceso a Grafana
http://localhost:3001
Usuario: admin
Password: admin123

# Dashboards disponibles:
- IA-Ops Overview
- Backstage Metrics
- OpenAI Service Performance
- Infrastructure Monitoring
```

---

## 🔒 **CONFIGURACIÓN DE SEGURIDAD**

### **CORS y Orígenes Permitidos**
```bash
# En .env
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3002,http://localhost:8080
CORS_ORIGINS=http://localhost:3000,http://localhost:3002,http://localhost:8080
```

### **Rate Limiting**
```bash
# En .env
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=60
```

### **Secrets Management**
```bash
# Claves importantes en .env
BACKEND_SECRET=Z72c/FuIlpZvf8M1lM8xyvS8h4Q6hl1TNJGujYbQeOM=
API_SECRET_KEY=your-secret-key-here
POSTGRES_PASSWORD=postgres123
REDIS_PASSWORD=redis123
```

---

## 🐛 **TROUBLESHOOTING**

### **Problemas Comunes**

#### **Puerto ya en uso**
```bash
# Verificar puertos ocupados
netstat -tulpn | grep :8080

# Cambiar puerto en .env
PROXY_PORT=9080

# Reiniciar
docker-compose down && docker-compose up -d
```

#### **Servicios no responden**
```bash
# Verificar logs
docker-compose logs [servicio]

# Reiniciar servicio específico
docker-compose restart [servicio]

# Verificar health checks
docker-compose ps
```

#### **Problemas de conectividad**
```bash
# Verificar red
docker network ls
docker network inspect ia-ops_ia-ops-network

# Verificar DNS interno
docker-compose exec backstage-backend nslookup postgres
```

---

## 📈 **ESCALABILIDAD**

### **Configuración para Producción**
```bash
# Variables de entorno para producción
ENVIRONMENT=production
DEBUG_MODE=false
LOG_LEVEL=warn

# Recursos optimizados
POSTGRES_MAX_CONNECTIONS=200
REDIS_MAXMEMORY=512mb
```

### **Load Balancing**
```yaml
# Ejemplo de escalado horizontal
backstage-backend:
  deploy:
    replicas: 3
    resources:
      limits:
        memory: 1G
        cpus: '0.5'
```

---

## 📚 **DOCUMENTACIÓN RELACIONADA**

- [Plan de Implementación](plan-implementacion.md)
- [Seguimiento de Progreso](seguimiento-progreso.md)
- [README Principal](../README.md)
- [Guía de Usuario](user-guide.md)
- [Troubleshooting](troubleshooting.md)

---

## 🎯 **PRÓXIMOS PASOS**

1. **Validación Completa**: Probar todos los endpoints y servicios
2. **Optimización**: Ajustar recursos según uso real
3. **Monitoreo**: Configurar alertas y dashboards adicionales
4. **Documentación**: Completar guías de usuario
5. **CI/CD**: Implementar pipeline de despliegue automático

---

**📊 Última actualización**: 8 de Agosto de 2025, 14:00 UTC  
**👤 Actualizado por**: Sistema de configuración consolidada  
**🔄 Próxima revisión**: 15 de Agosto de 2025
