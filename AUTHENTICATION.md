# Autenticación y Seguridad - Sistema de Facturación FactuMarket

## Descripción General

El sistema implementa autenticación basada en **JWT (JSON Web Tokens)** para proteger los endpoints de la API. Este mecanismo garantiza que solo aplicaciones autorizadas puedan acceder a los recursos del sistema.

## Arquitectura de Seguridad

### Componentes Principales

1. **ApiClient**: Modelo que almacena las credenciales permanentes de las aplicaciones autorizadas
2. **JsonWebToken**: Servicio encargado de codificar y decodificar tokens JWT
3. **AuthenticationController**: Controlador que gestiona el proceso de autenticación
4. **Authenticable**: Concern (módulo) que valida tokens en cada petición protegida

## Flujo de Autenticación

### Fase 1: Configuración Inicial

El administrador del sistema crea un registro `ApiClient` que representa una aplicación autorizada:

```ruby
ApiClient.create(name: 'Frontend Application')
# Genera automáticamente: api_key = "17d963077a6f57d1e2248cfc..."
```

**Campos del ApiClient:**
- `name`: Identificador descriptivo de la aplicación
- `api_key`: Clave secreta generada automáticamente (64 caracteres hexadecimales)

### Fase 2: Obtención del Token JWT

La aplicación cliente realiza una petición de autenticación:

**Request:**
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "api_key": "17d963077a6f57d1e2248cfc22c533345f9251f679865fffff26be10800498b3"
}
```

**Response (Éxito):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJhcGlfY2xpZW50X2lkIjoxLCJleHAiOjE3MzM2ODQ..."
}
```

**Response (Error):**
```json
{
  "error": "Invalid API Key"
}
```

**Proceso Interno:**
1. El sistema busca el `ApiClient` correspondiente al `api_key` proporcionado
2. Si existe, genera un token JWT con:
   - Payload: `{ api_client_id: 1, exp: timestamp }`
   - Expiración: 24 horas desde la emisión
   - Firma: Utiliza `Rails.application.secret_key_base`
3. Retorna el token al cliente

### Fase 3: Uso del Token en Peticiones Protegidas

Para acceder a endpoints protegidos, la aplicación debe incluir el token en el header `Authorization`:

**Request:**
```http
POST /api/v1/clients
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
Content-Type: application/json

{
  "client": {
    "company_name": "Panadería Don Pedro",
    "nit": "900123456-7",
    "email": "contacto@example.com",
    "address": "Calle 123 #45-67"
  }
}
```

**Validación Automática:**

El concern `Authenticable` intercepta la petición mediante un `before_action` y ejecuta:

1. Extrae el token del header `Authorization`
2. Decodifica el JWT usando la clave secreta de la aplicación
3. Verifica que no haya expirado
4. Si es válido → Permite continuar con la petición
5. Si es inválido/expirado → Retorna `401 Unauthorized`

## Endpoints Protegidos

Los siguientes endpoints requieren autenticación JWT:

- `POST /api/v1/clients` - Crear cliente
- `GET /api/v1/clients/:id` - Consultar cliente
- `PUT /api/v1/clients/:id` - Actualizar cliente
- `POST /api/v1/invoices` - Crear factura

## Endpoints Públicos

- `POST /api/v1/auth/login` - Obtener token JWT

## Códigos de Estado HTTP

| Código | Descripción |
|--------|-------------|
| 200 OK | Autenticación exitosa |
| 401 Unauthorized | Token inválido, expirado o ausente |
| 422 Unprocessable Entity | Datos de entrada inválidos |

## Seguridad Implementada

### Características de Seguridad

1. **Tokens con Expiración**: Los JWT expiran después de 24 horas
2. **Firma Criptográfica**: Utiliza HMAC-SHA256 para firmar tokens
3. **API Keys Únicas**: Cada `ApiClient` tiene una clave única de 64 caracteres
4. **Auditoría**: Todas las creaciones de `ApiClient` se registran en MongoDB

### Buenas Prácticas

- Las `api_key` deben almacenarse de forma segura (variables de entorno)
- Los tokens JWT deben transmitirse únicamente sobre HTTPS en producción
- Se recomienda implementar rate limiting para prevenir ataques de fuerza bruta
- Los tokens expirados deben renovarse mediante un nuevo login

## Ejemplo de Uso Completo

### 1. Obtener API Key (Administrador)

```bash
docker-compose exec web bundle exec rails console
> ApiClient.create(name: 'Mobile App')
> ApiClient.last.api_key
=> "17d963077a6f57d1e2248cfc22c533345f9251f679865fffff26be10800498b3"
```

### 2. Login (Aplicación Cliente)

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"api_key": "17d963077a6f57d1e2248cfc22c533345f9251f679865fffff26be10800498b3"}'
```

### 3. Usar Token

```bash
curl -X POST http://localhost:3000/api/v1/clients \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "client": {
      "company_name": "Panadería Don Pedro",
      "nit": "900123456-7",
      "email": "contacto@example.com",
      "address": "Calle 123 #45-67"
    }
  }'
```

## Diagrama de Flujo

```
┌─────────────────┐
│ Aplicación      │
│ Cliente         │
└────────┬────────┘
         │
         │ 1. POST /auth/login
         │    { api_key: "..." }
         ▼
┌─────────────────────────────┐
│ AuthenticationController    │
│ • Valida api_key            │
│ • Genera JWT (24h)          │
└────────┬────────────────────┘
         │
         │ 2. { token: "eyJ..." }
         ▼
┌─────────────────┐
│ Aplicación      │
│ (Almacena token)│
└────────┬────────┘
         │
         │ 3. POST /clients
         │    Authorization: Bearer eyJ...
         ▼
┌─────────────────────────────┐
│ Authenticable (Middleware)  │
│ • Decodifica JWT            │
│ • Valida expiración         │
└────────┬────────────────────┘
         │
         │ ✅ Token válido
         ▼
┌─────────────────────────────┐
│ ClientsController           │
│ • Procesa petición          │
│ • Registra auditoría        │
└─────────────────────────────┘
```

## Troubleshooting

### Error: "Unauthorized"

**Causa**: Token inválido o expirado

**Solución**: Realizar un nuevo login para obtener un token fresco

### Error: "Invalid API Key"

**Causa**: El `api_key` proporcionado no existe en la base de datos

**Solución**: Verificar que el `api_key` sea correcto o crear un nuevo `ApiClient`

### Token Expira Muy Rápido

**Solución**: Modificar la expiración en `app/lib/json_web_token.rb`:

```ruby
def self.encode(payload, exp = 48.hours.from_now) # Cambiar a 48 horas
  # ...
end
```
