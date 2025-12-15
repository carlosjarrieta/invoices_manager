#!/bin/bash

# Script de inicio para el Sistema de Facturación Electrónica
# Uso: ./bin/start.sh

set -e

echo "🚀 Iniciando Sistema de Facturación Electrónica..."
echo "=================================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar Docker
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker no está corriendo${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker está corriendo${NC}"
echo ""

# Levantar servicios
echo -e "${YELLOW}🚢 Levantando servicios...${NC}"
docker-compose up -d

echo ""
echo -e "${YELLOW}⏳ Esperando que las bases de datos Oracle estén listas...${NC}"

# Esperar a Oracle para Clientes
MAX_WAIT=180
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    ORACLE_CLIENTS_STATUS=$(docker inspect --format='{{.State.Health.Status}}' invoices_manager-oracle-clients-db-1 2>/dev/null || echo "starting")
    if [ "$ORACLE_CLIENTS_STATUS" = "healthy" ]; then
        echo -e "${GREEN}✅ Oracle para Clientes está listo!${NC}"
        break
    fi
    sleep 5
    WAITED=$((WAITED + 5))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "${RED}⚠️  Oracle para Clientes tardó demasiado${NC}"
fi

# Esperar a Oracle para Facturas
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    ORACLE_INVOICES_STATUS=$(docker inspect --format='{{.State.Health.Status}}' invoices_manager-oracle-invoices-db-1 2>/dev/null || echo "starting")
    if [ "$ORACLE_INVOICES_STATUS" = "healthy" ]; then
        echo -e "${GREEN}✅ Oracle para Facturas está listo!${NC}"
        break
    fi
    sleep 5
    WAITED=$((WAITED + 5))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "${RED}⚠️  Oracle para Facturas tardó demasiado${NC}"
fi

echo ""
echo -e "${YELLOW}🗄️  Ejecutando migraciones y seeds...${NC}"
./bin/migrate.sh

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Sistema listo!${NC}"
echo ""
echo "Servicios disponibles:"
echo "  • Clients Service:   http://localhost:3001"
echo "  • Invoices Service:  http://localhost:3002"
echo "  • Audit Service:     http://localhost:3003"