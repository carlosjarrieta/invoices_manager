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

# Verificar que docker-compose esté instalado
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Error: docker-compose no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ docker-compose está instalado${NC}"
echo ""

# Construir y levantar servicios
echo -e "${YELLOW}📦 Construyendo imágenes...${NC}"
docker-compose build

echo ""
echo -e "${YELLOW}🚢 Levantando servicios...${NC}"
docker-compose up -d

echo ""
echo -e "${YELLOW}⏳ Esperando que Oracle esté completamente listo...${NC}"
echo -e "${YELLOW}   (Esto puede tomar 1-3 minutos en el primer inicio)${NC}"

# Esperar a que Oracle esté healthy
MAX_WAIT=180  # 3 minutos máximo
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    ORACLE_STATUS=$(docker inspect --format='{{.State.Health.Status}}' invoices_manager-oracle-db-1 2>/dev/null || echo "starting")
    if [ "$ORACLE_STATUS" = "healthy" ]; then
        echo -e "${GREEN}✅ Oracle está listo!${NC}"
        break
    fi
    echo -e "${YELLOW}   Esperando Oracle... ($WAITED segundos)${NC}"
    sleep 10
    WAITED=$((WAITED + 10))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo -e "${RED}⚠️  Oracle tardó demasiado. Intentando continuar de todos modos...${NC}"
fi

# Esperar 10 segundos adicionales para asegurar que la base de datos esté lista
echo -e "${YELLOW}   Esperando 10 segundos adicionales para estabilidad...${NC}"
sleep 10

echo ""
echo -e "${YELLOW}🗄️  Configurando bases de datos...${NC}"

# Clients Service
echo -e "${YELLOW}  📋 Clients Service...${NC}"
docker-compose exec -T clients_service bundle exec rails db:create || true
docker-compose exec -T clients_service bundle exec rails db:migrate
docker-compose exec -T clients_service bundle exec rails db:seed

# Invoices Service
echo -e "${YELLOW}  📄 Invoices Service...${NC}"
docker-compose exec -T invoices_service bundle exec rails db:create || true
docker-compose exec -T invoices_service bundle exec rails db:migrate
docker-compose exec -T invoices_service bundle exec rails db:seed

echo ""
echo -e "${GREEN}✨ Sistema iniciado correctamente!${NC}"
echo ""
echo "=================================================="
echo -e "${GREEN}Servicios disponibles:${NC}"
echo ""
echo -e "  🔹 Clients Service:  ${YELLOW}http://localhost:3001${NC}"
echo -e "  🔹 Invoices Service: ${YELLOW}http://localhost:3002${NC}"
echo -e "  🔹 Audit Service:    ${YELLOW}http://localhost:3003${NC}"
echo ""
echo -e "${GREEN}Health Checks:${NC}"
echo -e "  curl http://localhost:3001/up"
echo -e "  curl http://localhost:3002/up"
echo -e "  curl http://localhost:3003/up"
echo ""
echo -e "${GREEN}Ver logs:${NC}"
echo -e "  docker-compose logs -f"
echo ""
echo -e "${GREEN}Detener servicios:${NC}"
echo -e "  docker-compose down"
echo ""
echo "=================================================="
