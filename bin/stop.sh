#!/bin/bash

# Script para detener el Sistema de Facturación Electrónica
# Uso: ./bin/stop.sh [--volumes]

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🛑 Deteniendo Sistema de Facturación Electrónica..."
echo "=================================================="
echo ""

# Verificar si se debe eliminar volúmenes
if [ "$1" == "--volumes" ]; then
    echo -e "${RED}⚠️  ADVERTENCIA: Esto eliminará todos los datos de las bases de datos${NC}"
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑️  Deteniendo servicios y eliminando volúmenes...${NC}"
        docker-compose down -v
        echo -e "${GREEN}✅ Servicios detenidos y volúmenes eliminados${NC}"
    else
        echo -e "${YELLOW}❌ Operación cancelada${NC}"
        exit 0
    fi
else
    echo -e "${YELLOW}🛑 Deteniendo servicios...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Servicios detenidos${NC}"
    echo ""
    echo -e "${YELLOW}ℹ️  Los datos de las bases de datos se han preservado${NC}"
    echo -e "${YELLOW}ℹ️  Para eliminar también los datos, usa: ./bin/stop.sh --volumes${NC}"
fi

echo ""
echo "=================================================="
