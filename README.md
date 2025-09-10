# IA-Ops Portal

Portal principal que integra todos los módulos de la solución IA-Ops para gestión inteligente de proyectos y operaciones.

## 🚀 Gestión de Servicios

```bash
# Script centralizado de gestión
./scripts/manage.sh [comando]

# Comandos principales
./scripts/manage.sh start          # Inicio inteligente (detecta automáticamente)
./scripts/manage.sh restart        # Reinicio completo (solo si hay servicios activos)
./scripts/manage.sh start-missing  # Solo servicios faltantes
./scripts/manage.sh stop           # Detener todos los servicios
./scripts/manage.sh status         # Estado detallado
./scripts/manage.sh diagnose       # Diagnóstico completo
./scripts/manage.sh check          # Verificar puertos
./scripts/manage.sh help           # Ayuda completa
```

## 🧠 Comportamiento Inteligente

### `start` - Inicio Automático ✨
- **Sin servicios**: Inicia todos desde cero
- **Algunos servicios**: Inicia solo los faltantes  
- **Todos activos**: Muestra estado y URLs disponibles

### `restart` - Reinicio Seguro 🔄
- Verifica servicios activos antes de reiniciar
- Si no hay servicios, sugiere usar `start`
- Reinicio completo: stop → espera → start

## 📊 URLs Principales

- **Backstage**: http://localhost:3000
- **Portal Docs**: http://localhost:8845 ✅
- **Dev-Core API**: http://localhost:8801
- **OpenAI API**: http://localhost:8000
- **MinIO Console**: http://localhost:9899

## 🔧 Últimas Mejoras

### v1.2.0 - Gestión Inteligente de Servicios
- ✅ **Inicio inteligente**: Detecta automáticamente qué servicios iniciar
- ✅ **Portal Docs corregido**: Ahora funciona correctamente en puerto 8845
- ✅ **Configuración MinIO**: Endpoints actualizados para conexión local
- ✅ **Scripts optimizados**: Mejor detección de servicios activos
- ✅ **Reinicio seguro**: Verificación previa antes de reiniciar

## 📁 Estructura

```
ia-ops/
├── scripts/           # Scripts de gestión centralizados
│   ├── manage.sh      # Script principal mejorado
│   ├── smart-start.sh # Inicio inteligente
│   └── smart-restart.sh # Reinicio seguro
├── ia-ops-*/         # Módulos de servicios
├── portal/           # Portal principal
├── modules/          # Módulos funcionales
└── config/           # Configuraciones
```

Para gestión completa usar: `./scripts/manage.sh help`
