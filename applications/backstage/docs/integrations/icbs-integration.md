# 🏦 Integración ICBS - Sistema Bancario Core

## 📋 Descripción
Sistema Bancario Core Integrado (ICBS) completamente integrado con la plataforma IA-Ops.

## 🏗️ Arquitectura ICBS

### Componentes Principales
- **Oracle Database XE**: Base de datos principal del sistema bancario
- **WebLogic Server A**: Servidor de aplicaciones primario (Puerto 7001)
- **WebLogic Server B**: Servidor de aplicaciones secundario (Puerto 7002)
- **HAProxy**: Load balancer y alta disponibilidad (Puerto 8083)

### Servicios de Soporte
- **Jenkins**: CI/CD para desarrollo ICBS (Puerto 8091)
- **SonarQube**: Análisis de calidad de código (Puerto 9000)
- **Nexus**: Gestión de artefactos Maven/Java (Puerto 8092)
- **Portainer**: Gestión de contenedores (Puerto 9080)

## 🔗 URLs de Acceso

### Servicios Core ICBS
- **WebLogic A Console**: http://localhost:7001/console
- **WebLogic B Console**: http://localhost:7002/console
- **HAProxy Load Balancer**: http://localhost:8083
- **HAProxy Statistics**: http://localhost:8404/stats
- **Oracle EM Express**: http://localhost:5500/em

### Servicios DevOps
- **Jenkins**: http://localhost:8091 (admin/admin123)
- **SonarQube**: http://localhost:9000 (admin/admin123)
- **Nexus**: http://localhost:8092 (admin/admin123)
- **Portainer**: http://localhost:9080

## 📊 Monitoreo y Observabilidad

### Métricas Disponibles
- **Prometheus**: Métricas de WebLogic y Oracle
- **Grafana**: Dashboards específicos para ICBS
- **Health Checks**: Monitoreo automático de servicios
- **Logs**: Centralizados por componente

### Dashboards Grafana
- **ICBS Overview**: Vista general del sistema
- **WebLogic Performance**: Métricas de servidores de aplicaciones
- **Oracle Database**: Performance y conexiones
- **HAProxy**: Load balancing y disponibilidad

## 🤖 Integración con IA

### OpenAI Service
- **Análisis de Código**: Revisión automática de código Java/J2EE
- **Recomendaciones**: Mejores prácticas bancarias
- **Documentación**: Generación automática de documentación técnica
- **Troubleshooting**: Asistencia para resolución de problemas

### Casos de Uso IA
- Análisis de performance de transacciones
- Recomendaciones de optimización de consultas
- Detección de patrones de uso anómalos
- Generación de reportes automáticos

## 🔧 Configuración y Despliegue

### Variables de Entorno
```bash
# Oracle Database
ORACLE_PASSWORD=oracle123
ORACLE_DATABASE=XEPDB1
ORACLE_USER=weblogic
ORACLE_USER_PASSWORD=weblogic123

# WebLogic
WEBLOGIC_ADMIN_PASSWORD=welcome1
WEBLOGIC_A_EXTERNAL_PORT=7001
WEBLOGIC_B_EXTERNAL_PORT=7002

# HAProxy
HAPROXY_HTTP_EXTERNAL_PORT=8083
HAPROXY_STATS_EXTERNAL_PORT=8404
```

### Comandos de Gestión
```bash
# Iniciar stack completo
cd /home/giovanemere/periferia/icbs/docker-for-oracle-weblogic
docker-compose -f config/docker-compose-no-mkdocs.yml up -d

# Ver estado
docker-compose -f config/docker-compose-no-mkdocs.yml ps

# Ver logs
docker-compose -f config/docker-compose-no-mkdocs.yml logs -f

# Parar servicios
docker-compose -f config/docker-compose-no-mkdocs.yml down
```

## 🚀 Desarrollo y CI/CD

### Pipeline Jenkins
1. **Source**: Código desde repositorios Git
2. **Build**: Compilación con Maven
3. **Test**: Pruebas unitarias y de integración
4. **Quality**: Análisis con SonarQube
5. **Package**: Generación de WARs/EARs
6. **Deploy**: Despliegue automático a WebLogic

### Gestión de Artefactos
- **Nexus**: Repositorio central de artefactos
- **Versionado**: Semantic versioning
- **Releases**: Gestión automática de releases
- **Dependencies**: Gestión de dependencias Maven

## 🔒 Seguridad

### Configuraciones de Seguridad
- **WebLogic Security**: Configuración de dominios seguros
- **Oracle Security**: Usuarios y roles específicos
- **HAProxy SSL**: Terminación SSL/TLS
- **Network Security**: Políticas de red definidas

### Credenciales por Defecto
- **WebLogic Admin**: weblogic/welcome1
- **Oracle SYS**: sys/oracle123
- **Jenkins**: admin/admin123
- **SonarQube**: admin/admin123
- **Nexus**: admin/admin123

## 📈 Performance y Escalabilidad

### Configuración de Performance
- **WebLogic Tuning**: JVM optimizada para transacciones bancarias
- **Oracle Tuning**: Configuración específica para OLTP
- **HAProxy**: Load balancing con health checks
- **Connection Pooling**: Pools optimizados

### Escalabilidad
- **Horizontal**: Agregar más servidores WebLogic
- **Vertical**: Incrementar recursos de contenedores
- **Database**: Configuración RAC para alta disponibilidad
- **Caching**: Estrategias de cache distribuido

## 🆘 Troubleshooting

### Problemas Comunes
1. **WebLogic no inicia**: Verificar Oracle Database
2. **HAProxy 503**: Verificar health checks de WebLogic
3. **Oracle conexión**: Verificar puertos y credenciales
4. **Performance lenta**: Revisar métricas en Grafana

### Logs Importantes
```bash
# WebLogic logs
docker logs weblogic-a
docker logs weblogic-b

# Oracle logs
docker logs orcldb

# HAProxy logs
docker logs haproxy
```

## 📞 Soporte

### Contactos
- **ICBS Team**: icbs-team@banco.com
- **DevOps**: devops@banco.com
- **DBA**: dba@banco.com

### Documentación Adicional
- [Manual de Administración WebLogic](./weblogic-admin.md)
- [Guía de Troubleshooting Oracle](./oracle-troubleshooting.md)
- [Configuración HAProxy](./haproxy-config.md)
