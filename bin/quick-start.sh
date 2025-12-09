#!/bin/bash

# Script de inicio rápido (sin construcción de imágenes)
# Uso: ./bin/quick-start.sh
# Nota: Usa este script si ya has ejecutado start.sh una vez

echo "🚀 Iniciando servicios rápidamente..."
echo "===================================="
echo ""

# Levantar servicios sin construir
docker-compose up -d

# Esperar 5 segundos a que se inicialicen
sleep 5

# Verificar estado
echo ""
echo "Estado de servicios:"
docker-compose ps

echo ""
echo "✅ Servicios levantados:"
echo "  • Clients Service:   http://localhost:3001"
echo "  • Invoices Service:  http://localhost:3002"
echo "  • Audit Service:     http://localhost:3003"
