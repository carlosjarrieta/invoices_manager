#!/bin/bash

echo "🧪 VERIFICACIÓN FINAL DEL SISTEMA"
echo "=================================="
echo ""

# Esperar un poco
echo "⏳ Esperando a que los servicios terminen de iniciar..."
sleep 30

echo ""
echo "📊 ESTADO DE LOS SERVICIOS:"
docker-compose ps 2>&1 | grep -E "invoices_manager" || echo "No se pudo obtener estado"

echo ""
echo "🔐 PRUEBA DE AUTENTICACIÓN CON api_client_id:"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3001/api/v1/authenticate \
  -H "Content-Type: application/json" \
  -d '{"api_client_id": 1}' 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Autenticación exitosa (HTTP $HTTP_CODE)"
  echo ""
  echo "📝 Respuesta:"
  echo "$BODY" | head -5
else
  echo "❌ Error en autenticación (HTTP $HTTP_CODE)"
  echo "$BODY"
fi

echo ""
echo "=================================="
echo "✨ Verificación completada"
