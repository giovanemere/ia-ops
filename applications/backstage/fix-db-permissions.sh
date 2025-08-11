#!/bin/bash

echo "🔧 CORRIGIENDO PERMISOS DE BASE DE DATOS DE BACKSTAGE"
echo "===================================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Lista de plugins con bases de datos
plugins=("auth" "catalog" "kubernetes" "permission" "proxy" "scaffolder" "search" "techdocs")

echo -e "${YELLOW}Cambiando propietario de bases de datos de plugins...${NC}"
echo ""

for plugin in "${plugins[@]}"; do
    db_name="backstage_plugin_$plugin"
    
    echo -n "Cambiando propietario de $db_name... "
    
    # Cambiar propietario de la base de datos
    docker exec ia-ops-postgres psql -U postgres -c "ALTER DATABASE $db_name OWNER TO backstage_user;" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅${NC}"
        
        # Cambiar propietario de todas las tablas en la base de datos
        docker exec ia-ops-postgres psql -U postgres -d "$db_name" -c "
            DO \$\$
            DECLARE
                r RECORD;
            BEGIN
                FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
                    EXECUTE 'ALTER TABLE ' || quote_ident(r.tablename) || ' OWNER TO backstage_user';
                END LOOP;
            END
            \$\$;
        " > /dev/null 2>&1
        
        # Cambiar propietario de secuencias
        docker exec ia-ops-postgres psql -U postgres -d "$db_name" -c "
            DO \$\$
            DECLARE
                r RECORD;
            BEGIN
                FOR r IN (SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public') LOOP
                    EXECUTE 'ALTER SEQUENCE ' || quote_ident(r.sequence_name) || ' OWNER TO backstage_user';
                END LOOP;
            END
            \$\$;
        " > /dev/null 2>&1
        
    else
        echo -e "${RED}❌${NC}"
    fi
done

echo ""
echo -e "${YELLOW}Otorgando permisos completos al usuario backstage_user...${NC}"
echo ""

for plugin in "${plugins[@]}"; do
    db_name="backstage_plugin_$plugin"
    
    echo -n "Configurando permisos para $db_name... "
    
    # Otorgar todos los permisos
    docker exec ia-ops-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO backstage_user;" > /dev/null 2>&1
    
    # Conectar a la base de datos y otorgar permisos en el schema public
    docker exec ia-ops-postgres psql -U postgres -d "$db_name" -c "
        GRANT ALL ON SCHEMA public TO backstage_user;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO backstage_user;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO backstage_user;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO backstage_user;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO backstage_user;
    " > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ PERMISOS CORREGIDOS EXITOSAMENTE${NC}"
echo ""
echo -e "${YELLOW}Verificando cambios...${NC}"

# Verificar propietarios
echo ""
echo "Propietarios de bases de datos:"
docker exec ia-ops-postgres psql -U postgres -c "
    SELECT datname, pg_catalog.pg_get_userbyid(datdba) as owner 
    FROM pg_database 
    WHERE datname LIKE 'backstage_plugin_%' 
    ORDER BY datname;
"

echo ""
echo -e "${GREEN}🎉 CORRECCIÓN COMPLETADA${NC}"
echo ""
echo "Ahora puedes reiniciar Backstage con:"
echo "  ./start-clean.sh"
