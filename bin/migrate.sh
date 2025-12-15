#!/bin/bash

# Script para ejecutar migraciones cuando los servicios ya están corriendo
# Uso: ./bin/migrate.sh

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🗄️  Ejecutando migraciones..."
echo "=================================================="
echo ""

# Verificar que las bases de datos Oracle estén healthy
echo -e "${YELLOW}Verificando estado de las bases de datos Oracle...${NC}"

# Verificar Oracle para Clientes
ORACLE_CLIENTS_STATUS=$(docker inspect --format='{{.State.Health.Status}}' invoices_manager-oracle-clients-db-1 2>/dev/null || echo "not_found")
if [ "$ORACLE_CLIENTS_STATUS" != "healthy" ]; then
    echo -e "${RED}❌ Oracle para Clientes no está listo (status: $ORACLE_CLIENTS_STATUS)${NC}"
    echo -e "${YELLOW}Espera a que Oracle esté healthy:${NC}"
    echo "  docker-compose logs -f oracle-clients-db"
    echo ""
    echo -e "${YELLOW}O ejecuta el script completo:${NC}"
    echo "  ./bin/start.sh"
    exit 1
fi

# Verificar Oracle para Facturas
ORACLE_INVOICES_STATUS=$(docker inspect --format='{{.State.Health.Status}}' invoices_manager-oracle-invoices-db-1 2>/dev/null || echo "not_found")
if [ "$ORACLE_INVOICES_STATUS" != "healthy" ]; then
    echo -e "${RED}❌ Oracle para Facturas no está listo (status: $ORACLE_INVOICES_STATUS)${NC}"
    echo -e "${YELLOW}Espera a que Oracle esté healthy:${NC}"
    echo "  docker-compose logs -f oracle-invoices-db"
    echo ""
    echo -e "${YELLOW}O ejecuta el script completo:${NC}"
    echo "  ./bin/start.sh"
    exit 1
fi

echo -e "${GREEN}✅ Ambas bases de datos Oracle están listas${NC}"
echo ""

# Clients Service
echo -e "${YELLOW}📋 Migrando Clients Service...${NC}"
docker-compose exec -T clients_service bundle exec rails db:migrate
docker-compose exec -T clients_service bundle exec rails db:seed
echo -e "${GREEN}✅ Clients Service migrado${NC}"
echo ""

# Invoices Service
echo -e "${YELLOW}📄 Migrando Invoices Service...${NC}"
docker-compose exec -T invoices_service bundle exec rails db:migrate
docker-compose exec -T invoices_service bundle exec rails db:seed
echo -e "${GREEN}✅ Invoices Service migrado${NC}"
echo ""

echo "=================================================="
echo -e "${GREEN}✨ Migraciones completadas!${NC}"
echo ""
echo -e "${GREEN}Verificar servicios:${NC}"
echo "  curl http://localhost:3001/up"
echo "  curl http://localhost:3002/up"
echo "  curl http://localhost:3003/up"
echo ""