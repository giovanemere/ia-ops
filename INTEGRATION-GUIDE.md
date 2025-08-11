# 🚀 Guía de Integración: IA-Ops + ICBS Platform

## 📋 Resumen de la Integración

Esta guía describe cómo usar la **solución integrada** que combina:
- **IA-Ops Platform** (Backstage + OpenAI Service)
- **ICBS** (Oracle WebLogic + Jenkins)

En lugar de manejar dos sistemas separados, ahora tienes **una plataforma unificada** con startup coordinado y monitoreo integrado.

## 🎯 ¿Por qué una Solución Integrada?

### ❌ Problema Anterior
- Dos sistemas separados que requerían inicio manual
- Comandos diferentes para cada plataforma
- Sin integración en el catálogo de Backstage
- Monitoreo fragmentado

### ✅ Solución Actual
- **Un solo comando** para iniciar toda la plataforma
- **Startup coordinado** con verificación de dependencias
- **ICBS registrado** en el catálogo de Backstage
- **Monitoreo unificado** en Grafana
- **Verificación automática** de servicios

## 🚀 Inicio Rápido

### Comando Principal (Recomendado)
```bash
# Desde el directorio principal de IA-Ops
cd /home/giovanemere/ia-ops/ia-ops
./start-integrated-platform.sh
```

### Comandos Alternativos
```bash
# Inicio completo con logs detallados
./scripts/integrated-startup.sh start

# Verificar estado de servicios
./scripts/verify-integration.sh

# Detener todos los servicios
./scripts/integrated-startup.sh stop
```

## 📊 Secuencia de Inicio

El script integrado ejecuta la siguiente secuencia:

### 1. 🔍 Verificaciones Previas
- ✅ Verificar directorios de IA-Ops e ICBS
- ✅ Limpiar puertos ocupados
- ✅ Validar configuraciones

### 2. 🏗️ Inicio de ICBS (Infraestructura Base)
```bash
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
./manage-services.sh start
```
- WebLogic Admin Server
- Jenkins CI/CD
- HAProxy Load Balancer

### 3. 🚀 Inicio de IA-Ops (Plataforma Principal)
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./kill-ports.sh
./generate-catalog-files.sh
./sync-env-config.sh
./start-robust.sh
```
- Backstage Frontend/Backend
- OpenAI Service
- Proxy Gateway
- Monitoring Stack

### 4. 🔗 Integración y Verificación
- Registro de ICBS en catálogo de Backstage
- Health checks de todos los servicios
- Configuración de monitoreo unificado

## 🌐 URLs de Acceso

### 🎯 Punto de Entrada Principal
- **IA-Ops Platform**: http://localhost:8080

### 🏛️ Servicios IA-Ops
- **Backstage Frontend**: http://localhost:3002
- **OpenAI Service**: http://localhost:8080/openai
- **Grafana**: http://localhost:3001 (admin/admin123)
- **Prometheus**: http://localhost:9090

### 🏗️ Servicios ICBS
- **WebLogic Console**: http://localhost:7001/console
- **Jenkins**: http://localhost:8081
- **HAProxy Stats**: http://localhost:8404/stats

## 🔧 Comandos de Gestión

### Inicio y Parada
```bash
# Iniciar plataforma completa
./start-integrated-platform.sh

# Detener todos los servicios
./scripts/integrated-startup.sh stop

# Reiniciar (detener + iniciar)
./scripts/integrated-startup.sh stop && ./scripts/integrated-startup.sh start
```

### Verificación y Diagnóstico
```bash
# Verificación completa
./scripts/verify-integration.sh

# Verificación rápida
./scripts/verify-integration.sh quick

# Ver URLs de acceso
./scripts/verify-integration.sh urls

# Estado de servicios
./scripts/integrated-startup.sh status
```

### Comandos Individuales (Si es necesario)
```bash
# Solo ICBS
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
./manage-services.sh start

# Solo Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./kill-ports.sh && ./generate-catalog-files.sh && ./sync-env-config.sh && ./start-robust.sh
```

## 📊 Monitoreo Integrado

### Dashboards Unificados
- **Grafana**: Vista consolidada de métricas IA-Ops + ICBS
- **Prometheus**: Recolección de métricas de ambas plataformas
- **Backstage**: Catálogo unificado con componentes ICBS

### Métricas Disponibles
- **IA-Ops**: Backstage, OpenAI Service, Proxy
- **ICBS**: WebLogic, Jenkins, HAProxy
- **Integración**: Health checks, conectividad

## 🔍 Troubleshooting

### Problemas Comunes

#### 1. Puertos Ocupados
```bash
# El script automáticamente limpia puertos, pero si persiste:
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./kill-ports.sh

# Verificar puertos manualmente
netstat -tuln | grep -E ':(8080|7001|8081|3002|7007)'
```

#### 2. ICBS No Inicia
```bash
# Verificar estado de ICBS
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
./manage-services.sh status

# Logs de ICBS
docker-compose logs -f
```

#### 3. Backstage No Responde
```bash
# Verificar logs de Backstage
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
tail -f backstage.log

# Reiniciar solo Backstage
./kill-ports.sh && ./start-robust.sh
```

#### 4. Servicios No Se Comunican
```bash
# Verificar conectividad
./scripts/verify-integration.sh

# Verificar configuración de red
docker network ls
```

### Logs y Diagnóstico
```bash
# Logs del startup integrado
tail -f /tmp/integrated-startup.log

# Logs de servicios individuales
docker-compose logs -f [servicio]

# Estado detallado
./scripts/verify-integration.sh verify
```

## 📁 Estructura de Archivos de Integración

```
ia-ops/
├── start-integrated-platform.sh          # 🚀 Script principal de inicio
├── scripts/
│   ├── integrated-startup.sh             # 🔧 Lógica de startup coordinado
│   └── verify-integration.sh             # 🔍 Verificación de servicios
├── config/
│   └── integrated-services.yaml          # ⚙️ Configuración de integración
└── applications/backstage/
    └── catalog-poc-icbs.yaml             # 📋 Catálogo ICBS en Backstage
```

## 🎯 Ventajas de la Integración

### ✅ Operacional
- **Un solo comando** para toda la plataforma
- **Startup coordinado** con manejo de dependencias
- **Verificación automática** de servicios
- **Monitoreo unificado**

### ✅ Desarrollo
- **ICBS visible** en catálogo de Backstage
- **Templates integrados** para WebLogic
- **CI/CD unificado** con Jenkins + Backstage
- **Documentación centralizada**

### ✅ Mantenimiento
- **Configuración centralizada**
- **Logs unificados**
- **Backup coordinado**
- **Troubleshooting simplificado**

## 🔄 Flujo de Trabajo Recomendado

### Desarrollo Diario
```bash
# 1. Iniciar plataforma
./start-integrated-platform.sh

# 2. Verificar que todo esté funcionando
./scripts/verify-integration.sh quick

# 3. Acceder a Backstage
open http://localhost:8080

# 4. Al finalizar el día
./scripts/integrated-startup.sh stop
```

### Desarrollo de Nuevas Funcionalidades
```bash
# 1. Iniciar con verificación completa
./start-integrated-platform.sh
./scripts/verify-integration.sh

# 2. Desarrollar en Backstage
# 3. Probar integración con ICBS
# 4. Verificar métricas en Grafana
```

## 📞 Soporte

### Archivos de Configuración
- **Variables de entorno**: `/home/giovanemere/ia-ops/ia-ops/.env`
- **Configuración integrada**: `/home/giovanemere/ia-ops/ia-ops/config/integrated-services.yaml`
- **Catálogo ICBS**: `/home/giovanemere/ia-ops/ia-ops/applications/backstage/catalog-poc-icbs.yaml`

### Comandos de Diagnóstico
```bash
# Estado completo
./scripts/verify-integration.sh verify

# Configuración actual
cat config/integrated-services.yaml

# Variables de entorno
grep -E '^[A-Z]' .env
```

---

## 🎉 ¡Listo para Usar!

Con esta integración, ya no necesitas manejar dos sistemas separados. **Un solo comando inicia toda tu plataforma de desarrollo**, con monitoreo unificado y verificación automática.

**Comando principal**: `./start-integrated-platform.sh`

¡Disfruta de tu plataforma integrada IA-Ops + ICBS! 🚀
