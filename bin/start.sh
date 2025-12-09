#!/bin/bash

# Script de inicio rápido para el Sistema de Facturación Electrónica
# Uso: ./bin/start.sh

set -e

echo "🚀 Iniciando Sistema de Facturación Electrónica..."
echo "=================================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar que Docker esté corriendo
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker no está corriendo${NC}"
    echo "Por favor inicia Docker Desktop y vuelve a intentar."
    exit 1
fi

echo -e "${GREEN}✅ Docker está corriendo${NC}"
echo ""

# Levantar servicios (sin construir si las imágenes ya existen)
echo -e "${YELLOW}🚢 Levantando servicios...${NC}"
docker-compose up -d

echo ""
echo -e "${YELLOW}⏳ Esperando que los servicios estén listos...${NC}"

# Esperar a que Oracle esté healthy (máximo 3 minutos)
MAX_WAIT=180
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    ORACLE_STATUS=$(docker inspect --format='{{.State.Health.Status}}' invoices_manager-oracle-db-1 2>/dev/null || echo "starting")
    if [ "$ORACLE_STATUS" = "healthy" ]; then
        echo -e "${GREEN}✅ Oracle está listo!${NC}"
        break
    fi
    sleep 5
    WAITED=$((WAITED + 5))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "${RED}⚠️  Oracle tardó demasiado. Continuando de todos modos...${NC}"
fi

echo ""
echo -e "${YELLOW}🗄️  Configurando bases de datos...${NC}"

# Clients Service
echo -e "${YELLOW}  📋 Clients Service${NC}"
docker-compose exec -T clients_service bundle exec rails db:create 2>/dev/null || true
docker-compose exec -T clients_service bundle exec rails db:migrate 2>/dev/null || true
docker-compose exec -T clients_service bundle exec rails db:seed 2>/dev/null || true

# Invoices Service
echo -e "${YELLOW}  📄 Invoices Service${NC}"
docker-compose exec -T invoices_service bundle exec rails db:create 2>/dev/null || true
docker-compose exec -T invoices_service bundle exec rails db:migrate 2>/dev/null || true
docker-compose exec -T invoices_service bundle exec rails db:seed 2>/dev/null || true

echo ""
echo -e "${GREEN}✨ Sistema iniciado!${NC}"
echo ""
echo "=================================================="
echo -e "${GREEN}Servicios disponibles:${NC}"
echo ""
echo -e "  🔹 Clients Service:  ${YELLOW}http://localhost:3001${NC}"
echo -e "  🔹 Invoices Service: ${YELLOW}http://localhost:3002${NC}"
echo -e "  🔹 Audit Service:    ${YELLOW}http://localhost:3003${NC}"
echo ""
echo -e "${GREEN}Verificar servicios:${NC}"
echo -e "  docker-compose ps"
echo ""
echo -e "${GREEN}Ver logs:${NC}"
echo -e "  docker-compose logs -f"
echo ""
echo "=================================================="
