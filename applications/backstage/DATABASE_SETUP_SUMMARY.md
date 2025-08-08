# 🗄️ Database Setup Summary - IA-OPS Backstage

## ✅ Configuration Status: RESOLVED

### Problem Solved:
- **SSL Connection Error**: Fixed by setting `ssl: false` in all configuration files
- **Database Not Found**: Created all required databases using the initialization script
- **Wrong Port**: Updated configuration to use port 5434 (actual PostgreSQL port)

## 📊 Database Configuration

### PostgreSQL Instance:
- **Host**: localhost
- **Port**: 5434
- **SSL**: Disabled (false)

### Databases Created:
1. **backstage_db** - For Backstage application
   - Owner: backstage_user
   - Password: backstage_pass_2025
   - Schemas: catalog, auth, techdocs, scaffolder, search

2. **grafana_db** - For Grafana dashboards
   - Owner: grafana_user
   - Password: grafana_pass_2025
   - Schemas: dashboards, users, alerts

3. **monitoring_db** - For OpenAI service analytics
   - Owner: monitoring_user
   - Password: monitoring_pass_2025
   - Schemas: metrics, logs, analytics

## 🔧 Configuration Files Updated:

### 1. `/home/giovanemere/ia-ops/ia-ops/.env`
```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5434
POSTGRES_SSL=false
```

### 2. `app-config.yaml`
```yaml
backend:
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST:-localhost}
      port: ${POSTGRES_PORT:-5434}
      user: ${BACKSTAGE_DB_USER:-backstage_user}
      password: ${BACKSTAGE_DB_PASSWORD:-backstage_pass_2025}
      database: ${BACKSTAGE_DB_NAME:-backstage_db}
      ssl: false
```

### 3. `app-config.development.yaml`
```yaml
backend:
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST:-localhost}
      port: ${POSTGRES_PORT:-5434}
      user: ${BACKSTAGE_DB_USER:-backstage_user}
      password: ${BACKSTAGE_DB_PASSWORD:-backstage_pass_2025}
      database: ${BACKSTAGE_DB_NAME:-backstage_db}
      ssl: false
```

### 4. `app-config.local.yaml`
```yaml
backend:
  database:
    client: pg
    connection:
      ssl: false
```

## ✅ Connection Test Results:
```
✅ PostgreSQL is running on port 5434
✅ backstage_db database exists
✅ backstage_user has proper permissions
✅ SSL is disabled
✅ Connection test successful
```

## 🚀 Next Steps:

1. **Start Backstage**:
   ```bash
   cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
   ./start.sh
   ```

2. **Or use yarn directly**:
   ```bash
   yarn start
   ```

3. **Access Backstage**:
   - Frontend: http://localhost:3002
   - Backend: http://localhost:7007

## 🐳 Docker vs Local Development:

### Current Setup (Local Development):
- PostgreSQL running locally on port 5434
- Backstage running locally with yarn
- Direct connection to local PostgreSQL

### Docker Setup (Alternative):
- All services in containers
- PostgreSQL in container on port 5432
- Automatic database initialization
- Use: `docker-compose up -d`

## 🔍 Troubleshooting:

If you encounter issues:

1. **Check PostgreSQL status**:
   ```bash
   sudo systemctl status postgresql
   ```

2. **Test database connection**:
   ```bash
   PGPASSWORD=backstage_pass_2025 psql -h localhost -p 5434 -U backstage_user -d backstage_db -c "SELECT 1;"
   ```

3. **Check environment variables**:
   ```bash
   cd /home/giovanemere/ia-ops/ia-ops/applications/backstage
   source ../../.env
   echo "Port: $POSTGRES_PORT, User: $BACKSTAGE_DB_USER"
   ```

## 📝 Notes:

- The database configuration is now aligned with the docker-compose.yml setup
- All three databases (backstage_db, grafana_db, monitoring_db) are ready
- SSL is properly disabled for local development
- The configuration supports both local and Docker deployment modes
