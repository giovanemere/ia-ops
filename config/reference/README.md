# 📁 Configuraciones de Referencia

Esta carpeta contiene configuraciones alternativas que **NO se están usando** actualmente en el proyecto, pero se mantienen como referencia para futuras implementaciones.

## 📄 Archivos

### `nginx-backstage.conf`
- **Propósito**: Configuración de Nginx para servir Backstage Frontend
- **Estado**: ❌ No utilizado
- **Alternativa actual**: Express.js con http-proxy-middleware en `applications/proxy-service/`
- **Uso potencial**: Si en el futuro se decide usar Nginx como proxy en lugar de Express

### `proxy-config-ready.js`
- **Propósito**: Configuración alternativa de proxy para Docker
- **Estado**: ❌ No utilizado  
- **Alternativa actual**: `applications/proxy-service/src/server.js`
- **Uso potencial**: Configuración de respaldo o para diferentes entornos

## 🔄 Implementación Actual

El proyecto actualmente usa:
- **Proxy Service**: Express.js con http-proxy-middleware
- **Ubicación**: `applications/proxy-service/src/server.js`
- **Puerto**: 8080
- **Funcionalidades**:
  - Rate limiting
  - CORS
  - Logging con Winston
  - Health checks
  - Proxy a Backstage Frontend/Backend
  - Proxy a OpenAI Service

## 📝 Notas

- Estos archivos se movieron desde la raíz del proyecto el 6 de Agosto de 2025
- Se mantienen por si se necesitan en futuras implementaciones
- **NO modificar** el docker-compose.yml o Dockerfiles para usar estos archivos
- La implementación actual funciona correctamente

## 🚀 Si quieres usar Nginx en el futuro

1. Crear servicio nginx en docker-compose.yml
2. Usar `nginx-backstage.conf` como base
3. Actualizar rutas y configuraciones
4. Modificar el proxy service o reemplazarlo

---

**⚠️ Importante**: Estos archivos están aquí solo como referencia. La implementación actual NO los usa.
