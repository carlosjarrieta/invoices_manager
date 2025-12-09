# Sistema de Facturación Electrónica - Prueba Técnica

Este proyecto es mi implementación de la prueba técnica para el puesto de Full Stack Developer Ruby en Double V Partners NYX. He desarrollado un sistema de facturación electrónica utilizando una **arquitectura de microservicios**, aplicando principios de **Clean Architecture** y el patrón **MVC**.

## 🏗️ Arquitectura del Sistema

### Arquitectura de Microservicios

He implementado **3 microservicios independientes** que se comunican entre sí:

#### 1. Clients Service (Puerto 3001)
- **Responsabilidad**: Gestión de información de clientes
- **Base de datos**: Oracle Database 23c Free
- **Funcionalidades**:
  - Crear clientes
  - Listar clientes
  - Consultar cliente por ID
  - Buscar cliente por NIT

#### 2. Invoices Service (Puerto 3002)
- **Responsabilidad**: Emisión y gestión de facturas electrónicas
- **Base de datos**: Oracle Database 23c Free
- **Arquitectura**: Clean Architecture implementada
- **Funcionalidades**:
  - Crear facturas
  - Listar facturas con filtros
  - Consultar factura por ID
  - Actualizar facturas

#### 3. Audit Service (Puerto 3003)
- **Responsabilidad**: Centralización de logs de auditoría
- **Base de datos**: MongoDB
- **Funcionalidades**:
  - Registrar eventos de auditoría
  - Consultar logs por entidad
  - Listar logs con paginación

### Comunicación entre Servicios

- **Invoices → Clients**: Validación de cliente existente (HTTP GET)
- **Clients → Audit**: Registro de operaciones de clientes (HTTP POST)
- **Invoices → Audit**: Registro de operaciones de facturas (HTTP POST)

### Tecnologías Utilizadas

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Lenguaje | Ruby | 3.2.2 |
| Framework | Ruby on Rails | 7.1.6 |
| Base de Datos Transaccional | Oracle Database | 23c Free |
| Base de Datos NoSQL | MongoDB | latest |
| Contenedorización | Docker & Docker Compose | latest |
| Autenticación | JWT | - |
| Arquitectura | Clean Architecture | - |

## 🚀 Cómo Levantar el Sistema

### Prerrequisitos

- Docker Desktop instalado y corriendo
- Mínimo 4GB de RAM disponible
- Puertos libres: 3001, 3002, 3003, 1521, 27017

### Opción 1: Inicio Rápido (Recomendado)

```bash
./bin/start.sh
```

**Tiempo**: ~2-3 minutos en el primer inicio (incluye construcción de imágenes)

Este script:
1. Levanta todos los servicios
2. Espera a que Oracle esté listo
3. Crea y migra las bases de datos
4. Carga datos de prueba

### Opción 2: Reinicio Rápido (Después del primer inicio)

Si ya has ejecutado `start.sh` una vez, puedes usar:

```bash
./bin/quick-start.sh
```

**Tiempo**: ~10 segundos (solo levanta servicios, sin reconstruir imágenes)

### Opción 3: Manual

```bash
# Levantar servicios
docker-compose up -d

# Esperar a que Oracle esté listo (ver logs)
docker-compose logs -f oracle-db

# Crear y migrar bases de datos
./bin/migrate.sh
```

## 🧪 Cómo Probar el Sistema

### 1. Obtener Token JWT

Primero necesitas un token de autenticación:

```bash
# Entrar a la consola del servicio de clientes
docker-compose exec clients_service bundle exec rails console
```

En la consola de Rails:

```ruby
# Obtener el primer cliente API creado por seeds
api_client = ApiClient.first
token = JsonWebToken.encode(api_client_id: api_client.id)
puts token
# Copiar el token que se muestra
exit
```

### 2. Importar Colecciones Postman

He incluido dos archivos con las colecciones completas:

- `FactuMarket_API.postman_collection.json`
- `FactuMarket_API.insomnia_collection.json`

**Importa cualquiera de estos archivos en tu cliente HTTP favorito.**

### 3. Configurar Variables de Entorno en Postman

En Postman, configura estas variables:

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `base_url_clients` | `http://localhost:3001` | URL del servicio de clientes |
| `base_url_invoices` | `http://localhost:3002` | URL del servicio de facturas |
| `base_url_audit` | `http://localhost:3003` | URL del servicio de auditoría |
| `jwt_token` | `TU_TOKEN_AQUI` | Token JWT obtenido arriba |

### 4. Flujo de Prueba Completo

#### Crear un Cliente
```bash
curl -X POST http://localhost:3001/api/v1/clients \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_TOKEN_JWT" \
  -d '{
    "company_name": "Mi Empresa SAS",
    "nit": "900111222-3",
    "email": "contacto@miempresa.com",
    "address": "Calle 123 #45-67",
    "phone": "3001234567"
  }'
```

#### Crear una Factura
```bash
curl -X POST http://localhost:3002/api/v1/invoices \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_TOKEN_JWT" \
  -d '{
    "client_id": 1,
    "amount": 1500000,
    "issue_date": "2024-12-08"
  }'
```

#### Ver Logs de Auditoría
```bash
curl -X GET "http://localhost:3003/api/v1/audit_logs/by_entity?entity=Invoice&entity_id=1" \
  -H "Authorization: Bearer TU_TOKEN_JWT"
```

## 🔍 Cómo Funciona la Auditoría Automática

Cuando creas una factura en `invoices_service`, **automáticamente** se crea una entrada en MongoDB:

### **Flujo:**

1. **Usuario crea una factura**
   ```bash
   POST http://localhost:3002/api/v1/invoices
   Body: {"client_id": 1, "amount": 2500000, "issue_date": "2024-12-09"}
   ```

2. **El CreateInvoice Use Case ejecuta:**
   - Valida los datos
   - Verifica que el cliente exista (consulta clients_service)
   - Guarda en Oracle
   - **Automáticamente llama a AuditAdapter**

3. **AuditAdapter envía HTTP POST a audit_service:**
   ```
   POST http://audit_service:3000/api/v1/audit_logs
   Body: {
     "action": "Invoice created",
     "entity": "Invoice",
     "entity_id": "1",
     "details": {
       "id": 1,
       "client_id": 1,
       "amount": 2500000
     },
     "ip_address": "192.168.65.1",
     "status": "SUCCESS"
   }
   ```

4. **audit_service guarda en MongoDB:**
   ```json
   {
     "_id": ObjectId("..."),
     "action": "Invoice created",
     "entity": "Invoice",
     "entity_id": "1",
     "details": { "id": 1, "client_id": 1, "amount": 2500000 },
     "ip_address": "192.168.65.1",
     "status": "SUCCESS",
     "created_at": "2024-12-09T09:30:00.000Z"
   }
   ```

### **Características:**

- ✅ **Asíncrono**: No bloquea la respuesta al usuario (usa Thread)
- ✅ **Resiliente**: Si falla la auditoría, no afecta la factura
- ✅ **Completo**: Registra éxitos y errores
- ✅ **Consultable**: Puedes ver todos los logs por entidad

### **Para Ver los Logs de una Factura:**

```bash
# Obtener token del audit service
TOKEN=$(curl -s -X POST http://localhost:3003/api/v1/authenticate \
  -H "Content-Type: application/json" \
  -d '{"api_client_id": 1}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Ver logs de la factura #1
curl -X GET "http://localhost:3003/api/v1/audit_logs/by_entity?entity=Invoice&entity_id=1" \
  -H "Authorization: Bearer $TOKEN"
```

## 📁 Estructura del Proyecto

```
invoices_manager/
├── apps/                           # Microservicios
│   ├── clients_service/           # Servicio de Clientes
│   │   ├── app/
│   │   │   ├── controllers/
│   │   │   ├── models/
│   │   │   └── services/
│   │   ├── config/
│   │   ├── db/
│   │   ├── Dockerfile
│   │   └── Gemfile
│   ├── invoices_service/          # Servicio de Facturas
│   │   ├── app/
│   │   │   ├── controllers/
│   │   │   ├── models/
│   │   │   └── lib/invoicing/    # Clean Architecture
│   │   │       ├── entities/
│   │   │       ├── use_cases/
│   │   │       └── infrastructure/
│   │   ├── config/
│   │   ├── db/
│   │   ├── Dockerfile
│   │   └── Gemfile
│   └── audit_service/             # Servicio de Auditoría
│       ├── app/
│       ├── config/
│       ├── Dockerfile
│       └── Gemfile
├── bin/                            # Scripts de utilidad
│   ├── start.sh                   # Inicio automatizado
│   ├── migrate.sh                 # Solo migraciones
│   ├── check.sh                   # Verificación de estado
│   └── stop.sh                    # Detener servicios
├── doc/                            # Documentación adicional
├── docker-compose.yml             # Orquestación de servicios
├── FactuMarket_API.postman_collection.json
├── FactuMarket_API.insomnia_collection.json
├── README.md                      # Este archivo
└── .gitignore
```

## 🏛️ Clean Architecture en Invoices Service

He aplicado Clean Architecture específicamente en el servicio de facturas, que es el más complejo. La estructura sigue los principios de Uncle Bob:

### Capas Implementadas

#### 1. Entities (Reglas de Negocio)
```ruby
# app/lib/invoicing/entities/invoice.rb
module Invoicing
  module Entities
    class Invoice
      attr_reader :client_id, :amount, :issue_date

      def initialize(client_id:, amount:, issue_date:)
        @client_id = client_id
        @amount = amount
        @issue_date = issue_date
        validate!
      end

      private

      def validate!
        raise ArgumentError, "Amount must be positive" if amount <= 0
        raise ArgumentError, "Issue date cannot be in the future" if issue_date > Date.today
      end
    end
  end
end
```

#### 2. Use Cases (Orquestación)
```ruby
# app/lib/invoicing/use_cases/create_invoice.rb
module Invoicing
  module UseCases
    class CreateInvoice
      def initialize(client_gateway:, audit_adapter:, invoice_repository:)
        @client_gateway = client_gateway
        @audit_adapter = audit_adapter
        @invoice_repository = invoice_repository
      end

      def execute(client_id:, amount:, issue_date:)
        # Validar cliente
        client = @client_gateway.find_client(client_id)
        raise "Client not found" unless client

        # Crear entidad
        invoice_entity = Entities::Invoice.new(
          client_id: client_id,
          amount: amount,
          issue_date: issue_date
        )

        # Guardar
        record = @invoice_repository.save(invoice_entity)

        # Auditar
        @audit_adapter.log_event(
          entity: "Invoice",
          entity_id: record.id,
          action: "created",
          details: { amount: amount, client_id: client_id }
        )

        record
      end
    end
  end
end
```

#### 3. Infrastructure (Adaptadores)
```ruby
# app/lib/invoicing/infrastructure/client_gateway.rb
module Invoicing
  module Infrastructure
    class ClientGateway
      def find_client(client_id)
        # Comunicación HTTP con Clients Service
        response = HTTP.get("#{ENV['CLIENTS_SERVICE_URL']}/api/v1/clients/#{client_id}")
        JSON.parse(response.body) if response.status.success?
      end
    end
  end
end
```

### Beneficios de Clean Architecture

- ✅ **Independencia de Frameworks**: El código de negocio no depende de Rails
- ✅ **Testabilidad**: Cada capa se puede probar independientemente
- ✅ **Mantenibilidad**: Cambios en una capa no afectan otras
- ✅ **Escalabilidad**: Fácil agregar nuevas funcionalidades

## 🔧 Variables de Entorno

### Variables Requeridas

| Variable | Servicio | Valor por Defecto | Descripción |
|----------|----------|-------------------|-------------|
| `ORACLE_HOST` | Clients, Invoices | `oracle-db` | Host de Oracle |
| `ORACLE_PORT` | Clients, Invoices | `1521` | Puerto de Oracle |
| `ORACLE_DATABASE` | Clients, Invoices | `XEPDB1` | Nombre de BD |
| `ORACLE_USERNAME` | Clients, Invoices | `system` | Usuario Oracle |
| `ORACLE_PASSWORD` | Clients, Invoices | `password123` | Password Oracle |
| `CLIENTS_SERVICE_URL` | Invoices | `http://clients_service:3000` | URL del servicio de clientes |
| `AUDIT_SERVICE_URL` | Clients, Invoices | `http://audit_service:3000` | URL del servicio de auditoría |
| `MONGO_HOST` | Audit | `mongo-db` | Host de MongoDB |
| `MONGO_PORT` | Audit | `27017` | Puerto de MongoDB |
| `MONGO_DATABASE` | Audit | `audit_logs` | Base de datos MongoDB |

### Configuración en Docker

Todas estas variables están preconfiguradas en `docker-compose.yml`. No necesitas configurar nada manualmente.

## 🐛 Solución de Problemas

### Error: "ORA-01005: null password given"

**Causa**: Oracle aún no está listo.

**Solución**:
```bash
# Ver logs de Oracle
docker-compose logs -f oracle-db

# Esperar hasta ver "DATABASE IS READY TO USE!"
# Luego ejecutar migraciones
./bin/migrate.sh
```

### Error: "executable file not found: rails"

**Solución**: Usar siempre `bundle exec rails`:
```bash
docker-compose exec clients_service bundle exec rails db:migrate
```

### Servicios no responden

```bash
# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f [nombre_servicio]

# Reiniciar
docker-compose restart [nombre_servicio]
```

### Resetear todo

```bash
# Detener y eliminar datos
docker-compose down -v

# Reconstruir desde cero
docker-compose build --no-cache
./bin/start.sh
```

## 📊 Endpoints de la API

### Clients Service (3001)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/clients` | Crear cliente |
| GET | `/api/v1/clients` | Listar clientes |
| GET | `/api/v1/clients/:id` | Consultar cliente |
| GET | `/api/v1/clients/search_by_nit?nit=XXX` | Buscar por NIT |

### Invoices Service (3002)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/invoices` | Crear factura |
| GET | `/api/v1/invoices` | Listar facturas |
| GET | `/api/v1/invoices/:id` | Consultar factura |
| PUT/PATCH | `/api/v1/invoices/:id` | Actualizar factura |

### Audit Service (3003)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/audit_logs` | Crear log de auditoría |
| GET | `/api/v1/audit_logs` | Listar logs |
| GET | `/api/v1/audit_logs/:id` | Consultar log |
| GET | `/api/v1/audit_logs/by_entity?entity=X&entity_id=Y` | Filtrar por entidad |

## 🎯 Decisiones de Arquitectura

### ¿Por qué Microservicios?

1. **Escalabilidad**: Cada servicio se puede escalar independientemente
2. **Mantenibilidad**: Equipos pueden trabajar en servicios diferentes
3. **Tecnologías**: Cada servicio puede usar la tecnología más apropiada
4. **Resiliencia**: Un servicio caído no afecta los demás

### ¿Por qué Clean Architecture?

1. **Reglas de Negocio Protegidas**: Independientes de frameworks
2. **Testabilidad**: Código fácil de probar
3. **Mantenibilidad**: Cambios localizados
4. **Evolución**: Fácil agregar nuevas funcionalidades

### ¿Por qué Oracle + MongoDB?

- **Oracle**: Para datos transaccionales que requieren ACID
- **MongoDB**: Para logs de auditoría (documentos flexibles)

## 📈 Métricas del Proyecto

- **Líneas de código**: ~4,000
- **Microservicios**: 3
- **Endpoints API**: 12
- **Pruebas unitarias**: 15+ (capa de dominio completa)
- **Tiempo de desarrollo**: 2 semanas
- **Cobertura de requisitos**: 100%

## 🧪 Pruebas Unitarias

He implementado pruebas unitarias completas en la capa de dominio de todos los microservicios, siguiendo principios de TDD y Clean Architecture:

### Invoices Service
- **Entidad Invoice**: Validaciones de negocio, inicialización
- **Caso de uso CreateInvoice**: Escenarios exitosos y de error con mocks

### Clients Service  
- **Modelo Client**: Validaciones de ActiveRecord, unicidad, formato
- **Servicio AuditService**: Envío de logs HTTP, manejo de errores

### Audit Service
- **Modelo AuditLog**: Persistencia en MongoDB, campos requeridos

**Ejecutar pruebas:**
```bash
# Servicio de facturas
cd apps/invoices_service && rails test test/lib/invoicing/

# Servicio de clientes  
cd apps/clients_service && rails test test/models/ test/services/

# Servicio de auditoría
cd apps/audit_service && rails test test/models/
```

Las pruebas usan `mocha` para mocks y no dependen de bases de datos externas.

## 📞 Contacto

Este proyecto fue desarrollado como parte de mi aplicación para el puesto de Full Stack Developer Ruby en Double V Partners NYX.

**Desarrollador**: Carlos Javier Arrieta Jimenez
**Email**: carlosj.arrieta@gmail.com
**Celular**: 3042075846
**Repositorio**: https://github.com/carlosjarrieta/invoices_manager
**Fecha**: Diciembre 2025
**Tecnologías**: Ruby 3.2.2, Rails 7.1.6, Oracle 23c, MongoDB, Docker

---

**¡Gracias por revisar mi implementación!** 🚀