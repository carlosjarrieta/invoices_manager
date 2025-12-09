#!/bin/bash

echo "🧪 PRUEBA COMPLETA DEL SISTEMA"
echo "======================================"
echo ""

echo "1️⃣  Verificando contenedores..."
docker ps --format "table {{.Names}}\t{{.Status}}" | grep invoices_manager || echo "Contenedores no encontrados"

echo ""
echo "2️⃣  Probando Clients Service..."
curl -s http://localhost:3001/up > /dev/null && echo "✅ Clients responde" || echo "❌ Clients no responde"

echo ""
echo "3️⃣  Probando Invoices Service..."
curl -s http://localhost:3002/up > /dev/null && echo "✅ Invoices responde" || echo "❌ Invoices no responde"

echo ""
echo "4️⃣  Probando Audit Service..."
curl -s http://localhost:3003/up > /dev/null && echo "✅ Audit responde" || echo "❌ Audit no responde"

echo ""
echo "5️⃣  Probando autenticación con api_client_id..."
RESPONSE=$(curl -s -X POST http://localhost:3001/api/v1/authenticate \
  -H "Content-Type: application/json" \
  -d '{"api_client_id": 1}')

TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
  echo "✅ Token generado: ${TOKEN:0:30}..."
  
  echo ""
  echo "6️⃣  Probando request con token..."
  curl -s http://localhost:3001/api/v1/clients \
    -H "Authorization: Bearer $TOKEN" > /dev/null && echo "✅ Clients API con autenticación OK" || echo "❌ Error en API"
else
  echo "❌ Error al generar token"
  echo "Respuesta: $RESPONSE"
fi

echo ""
echo "======================================"
echo "✨ Prueba completada"
