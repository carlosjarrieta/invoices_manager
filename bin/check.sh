#!/bin/bash

# Script de verificación del estado del sistema
# Uso: ./bin/check.sh

echo "🔍 Verificando Estado del Sistema de Facturación"
echo "=================================================="
echo ""

# Verificar Docker
echo "1️⃣ Docker:"
if docker info > /dev/null 2>&1; then
    echo "   ✅ Docker está corriendo"
else
    echo "   ❌ Docker NO está corriendo"
    exit 1
fi
echo ""

# Verificar contenedores
echo "2️⃣ Contenedores:"
docker ps --format "   {{.Names}}\t{{.Status}}" | grep invoices_manager || echo "   ⚠️  No hay contenedores corriendo"
echo ""

# Verificar Oracle
echo "3️⃣ Estado de Oracle:"
ORACLE_STATUS=$(docker inspect --format='{{.State.Health.Status}}' invoices_manager-oracle-db-1 2>/dev/null || echo "no encontrado")
if [ "$ORACLE_STATUS" = "healthy" ]; then
    echo "   ✅ Oracle está healthy"
elif [ "$ORACLE_STATUS" = "starting" ]; then
    echo "   ⏳ Oracle está iniciando..."
elif [ "$ORACLE_STATUS" = "unhealthy" ]; then
    echo "   ❌ Oracle está unhealthy"
else
    echo "   ⚠️  Oracle no encontrado"
fi
echo ""

# Health checks de servicios
echo "4️⃣ Health Checks:"
echo -n "   Clients (3001): "
if curl -s http://localhost:3001/up > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

echo -n "   Invoices (3002): "
if curl -s http://localhost:3002/up > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

echo -n "   Audit (3003): "
if curl -s http://localhost:3003/up > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi
echo ""

echo "=================================================="
echo "Comandos útiles:"
echo "  Ver logs:          docker-compose logs -f"
echo "  Ver logs Oracle:   docker-compose logs -f oracle-db"
echo "  Estado:            docker-compose ps"
echo "  Reiniciar:         docker-compose restart"
echo "  Detener:           docker-compose down"
echo ""
