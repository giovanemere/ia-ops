# Entorno de Desarrollo

## 🛠️ Configuración de Desarrollo

### Inicio Rápido

```bash
# Clonar repositorio
git clone git@github.com:giovanemere/ia-ops.git
cd ia-ops

# Iniciar todos los servicios
./start-services-safe.sh

# Verificar servicios
curl http://localhost:3000  # Backstage
curl http://localhost:8000  # Docs
curl http://localhost:8080  # Dev-Core
```

### Servicios de Desarrollo

| Servicio | Puerto | Comando | Estado |
|----------|--------|---------|--------|
| Backstage | 3000 | `./scripts/start-development.sh` | ✅ |
| Docs | 8000 | `./start_portal.sh` | ✅ |
| Dev-Core | 8080 | `./manage-complete.sh start` | ✅ |
| Veritas | 8081 | `./scripts/start-unified.sh` | ✅ |
| MinIO | 9000/9001 | `./scripts/manage.sh start` | ✅ |
| PostgreSQL | 5432 | `./scripts/manage.sh start` | ✅ |

### Hot Reload

```bash
# Frontend con hot reload
cd portal/frontend
npm run dev

# Backend con nodemon
cd portal/backend  
npm run dev

# Docs con auto-reload
./serve-docs.sh
```

### Base de Datos de Desarrollo

```bash
# Reset completo
npm run db:reset

# Solo migraciones
npm run db:migrate

# Seed de datos de prueba
npm run db:seed:dev
```

### Testing

```bash
# Tests unitarios
npm run test

# Tests de integración
npm run test:integration

# Coverage
npm run test:coverage

# E2E tests
npm run test:e2e
```

### Debugging

```bash
# Backend con debugger
npm run dev:debug

# Frontend con React DevTools
npm run dev:react-debug
```
