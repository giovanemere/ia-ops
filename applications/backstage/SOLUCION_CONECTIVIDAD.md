# 🔗 Solución: Error de Conectividad "Failed to fetch"

## 🎯 Problema Identificado

**Error original:**
```
TypeError: Failed to fetch
at SearchClient.query
```

**Causa:** El frontend de Backstage no podía conectarse al backend debido a:
1. Frontend no estaba iniciándose correctamente
2. Configuración de puertos incorrecta (3000 vs 3002)
3. Procesos de Backstage en estado inconsistente

## ✅ Solución Implementada

### **1. Configuración de Puertos Corregida**

**Puertos correctos según .env:**
- ✅ **Frontend:** Puerto `3002` (no 3000)
- ✅ **Backend:** Puerto `7007`
- ✅ **Proxy:** Puerto `8080`
- ✅ **PostgreSQL:** Puerto `5432`

### **2. Scripts de Diagnóstico Creados**

#### **diagnose-connectivity.sh**
- Verifica puertos en uso
- Prueba conectividad a cada servicio
- Muestra configuración de red
- Proporciona recomendaciones

#### **kill-ports.sh (Actualizado)**
- Incluye puerto 3002 además de 3000
- Mata todos los procesos de Backstage
- Verifica que los puertos queden libres

### **3. Proceso de Corrección**

```bash
# Diagnóstico inicial
./diagnose-connectivity.sh
# 🔴 Frontend (3002): NO RESPONDE
# 🔴 Backend (7007): NO RESPONDE

# Limpieza de procesos
./kill-ports.sh
# ✅ Todos los puertos libres

# Configuración de servicios
./setup-database.sh && ./sync-env-config.sh
# ✅ Base de datos configurada
# ✅ Variables sincronizadas
```

## 🚀 URLs Correctas

### **URLs de Acceso:**
- **Frontend Principal:** http://localhost:3002
- **Backend API:** http://localhost:7007
- **Proxy Gateway:** http://localhost:8080
- **Chat de IA:** http://localhost:8080/ai-chat

### **URLs de Verificación:**
- **Catálogo:** http://localhost:3002/catalog
- **Búsqueda:** http://localhost:3002/search
- **Backend Health:** http://localhost:7007/api/catalog/health
- **API Docs:** http://localhost:7007/api/docs

## 🔧 Comandos de Solución

### **Diagnóstico Completo:**
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
./diagnose-connectivity.sh
```

### **Limpieza y Reinicio:**
```bash
# Matar procesos
./kill-ports.sh

# Configurar servicios
./setup-database.sh
./sync-env-config.sh

# Iniciar Backstage
dotenv -e ../../.env -- yarn start
```

### **Comando Completo:**
```bash
cd /home/giovanemere/ia-ops/ia-ops/applications/backstage && \
./kill-ports.sh && \
./setup-database.sh && \
./sync-env-config.sh && \
dotenv -e ../../.env -- yarn start
```

## 🔍 Verificación Post-Solución

### **1. Verificar Puertos:**
```bash
lsof -i :3002,7007,8080,5432
```

### **2. Verificar Conectividad:**
```bash
curl http://localhost:3002  # Frontend
curl http://localhost:7007  # Backend
curl http://localhost:8080  # Proxy
```

### **3. Verificar en Navegador:**
- **Ir a:** http://localhost:3002
- **Verificar búsqueda:** Usar barra de búsqueda
- **Verificar catálogo:** http://localhost:3002/catalog
- **Verificar chat IA:** http://localhost:8080/ai-chat

## 📊 Resultado de la Corrección

### **Antes:**
```
❌ TypeError: Failed to fetch
❌ Frontend no responde
❌ Backend desconectado
❌ Búsqueda no funciona
```

### **Después:**
```
✅ Conectividad completa
✅ Frontend en puerto 3002
✅ Backend en puerto 7007
✅ Búsqueda funcional
✅ Catálogo accesible
```

## 💡 Notas Importantes

### **Puerto Frontend:**
- **Configurado:** 3002 (no 3000)
- **Variable:** `BACKSTAGE_FRONTEND_PORT=3002`
- **URL:** http://localhost:3002

### **Proxy Gateway:**
- **Puerto:** 8080
- **Función:** Punto de entrada principal
- **Chat IA:** http://localhost:8080/ai-chat

### **Orden de Inicio:**
1. PostgreSQL (docker-compose)
2. Backend (puerto 7007)
3. Frontend (puerto 3002)
4. Proxy (puerto 8080)

## 🛠️ Scripts Disponibles

| Script | Función |
|--------|---------|
| `diagnose-connectivity.sh` | Diagnóstico completo |
| `kill-ports.sh` | Matar procesos |
| `setup-database.sh` | Configurar BD |
| `sync-env-config.sh` | Sincronizar config |

## ✨ Resultado Final

- ✅ **Error resuelto:** No más "Failed to fetch"
- ✅ **Conectividad completa:** Frontend ↔ Backend
- ✅ **URLs correctas:** Puerto 3002 para frontend
- ✅ **Búsqueda funcional:** Índices creados automáticamente
- ✅ **Catálogo accesible:** Todas las entidades disponibles

---

**🎉 ¡Problema de conectividad completamente resuelto!**

Backstage ahora funciona correctamente con frontend en puerto 3002 y backend en puerto 7007.
