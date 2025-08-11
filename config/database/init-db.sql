-- =============================================================================
-- IA-OPS DATABASE INITIALIZATION SCRIPT
-- =============================================================================
-- Fecha: 8 de Agosto de 2025
-- Propósito: Inicializar todas las bases de datos y usuarios necesarios
-- =============================================================================

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- BACKSTAGE DATABASE SETUP
-- =============================================================================

-- Crear usuario de Backstage con permisos completos
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'backstage_user') THEN
        CREATE ROLE backstage_user WITH LOGIN PASSWORD 'backstage_pass_2025';
    END IF;
END
$$;

-- Otorgar permisos de creación de bases de datos
ALTER ROLE backstage_user CREATEDB;
ALTER ROLE backstage_user CREATEROLE;

-- Crear base de datos principal de Backstage
DROP DATABASE IF EXISTS backstage_db;
CREATE DATABASE backstage_db OWNER backstage_user;

-- Crear base de datos adicional para plugins
DROP DATABASE IF EXISTS backstage_plugin_app;
CREATE DATABASE backstage_plugin_app OWNER backstage_user;

-- Otorgar todos los permisos en las bases de datos
GRANT ALL PRIVILEGES ON DATABASE backstage_db TO backstage_user;
GRANT ALL PRIVILEGES ON DATABASE backstage_plugin_app TO backstage_user;

-- Conectar a backstage_db para configurar esquemas
\c backstage_db;

-- Crear esquemas necesarios
CREATE SCHEMA IF NOT EXISTS catalog AUTHORIZATION backstage_user;
CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION backstage_user;
CREATE SCHEMA IF NOT EXISTS techdocs AUTHORIZATION backstage_user;
CREATE SCHEMA IF NOT EXISTS scaffolder AUTHORIZATION backstage_user;
CREATE SCHEMA IF NOT EXISTS search AUTHORIZATION backstage_user;
CREATE SCHEMA IF NOT EXISTS proxy AUTHORIZATION backstage_user;
CREATE SCHEMA IF NOT EXISTS permission AUTHORIZATION backstage_user;

-- Otorgar permisos en esquemas
GRANT ALL ON SCHEMA public TO backstage_user;
GRANT ALL ON SCHEMA catalog TO backstage_user;
GRANT ALL ON SCHEMA auth TO backstage_user;
GRANT ALL ON SCHEMA techdocs TO backstage_user;
GRANT ALL ON SCHEMA scaffolder TO backstage_user;
GRANT ALL ON SCHEMA search TO backstage_user;
GRANT ALL ON SCHEMA proxy TO backstage_user;
GRANT ALL ON SCHEMA permission TO backstage_user;

-- Otorgar permisos en todas las tablas existentes y futuras
GRANT ALL ON ALL TABLES IN SCHEMA public TO backstage_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO backstage_user;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO backstage_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO backstage_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO backstage_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO backstage_user;

-- Conectar a backstage_plugin_app para configurar esquemas
\c backstage_plugin_app;

-- Crear esquemas necesarios para plugins
CREATE SCHEMA IF NOT EXISTS plugins AUTHORIZATION backstage_user;
CREATE SCHEMA IF NOT EXISTS integrations AUTHORIZATION backstage_user;

-- Otorgar permisos en esquemas de plugins
GRANT ALL ON SCHEMA public TO backstage_user;
GRANT ALL ON SCHEMA plugins TO backstage_user;
GRANT ALL ON SCHEMA integrations TO backstage_user;

-- Otorgar permisos en todas las tablas existentes y futuras
GRANT ALL ON ALL TABLES IN SCHEMA public TO backstage_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO backstage_user;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO backstage_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO backstage_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO backstage_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO backstage_user;

-- Volver a la base de datos principal
\c postgres;

-- =============================================================================
-- GRAFANA DATABASE SETUP
-- =============================================================================

-- Crear usuario de Grafana
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'grafana_user') THEN
        CREATE ROLE grafana_user WITH LOGIN PASSWORD 'grafana_pass_2025';
    END IF;
END
$$;

-- Crear base de datos de Grafana
DROP DATABASE IF EXISTS grafana_db;
CREATE DATABASE grafana_db OWNER grafana_user;
GRANT ALL PRIVILEGES ON DATABASE grafana_db TO grafana_user;

-- =============================================================================
-- MONITORING DATABASE SETUP
-- =============================================================================

-- Crear usuario de monitoreo
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'monitoring_user') THEN
        CREATE ROLE monitoring_user WITH LOGIN PASSWORD 'monitoring_pass_2025';
    END IF;
END
$$;

-- Crear base de datos de monitoreo
DROP DATABASE IF EXISTS monitoring_db;
CREATE DATABASE monitoring_db OWNER monitoring_user;
GRANT ALL PRIVILEGES ON DATABASE monitoring_db TO monitoring_user;

-- =============================================================================
-- CONFIGURACIÓN FINAL
-- =============================================================================

-- Mostrar resumen de bases de datos creadas
\l

-- Mostrar usuarios creados
\du

-- Mensaje de confirmación
\echo '✅ Database initialization completed successfully!'
\echo '📊 Databases created:'
\echo '   - backstage_db (owner: backstage_user)'
\echo '   - backstage_plugin_app (owner: backstage_user)'
\echo '   - grafana_db (owner: grafana_user)'
\echo '   - monitoring_db (owner: monitoring_user)'
\echo '🔐 All users have appropriate permissions'
\echo '🚀 Ready for Backstage migration!'
