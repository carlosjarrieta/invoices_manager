# README

## Utils commands

# 1. Bajar todo y eliminar volúmenes
docker-compose down -v

# 2. Limpiar imágenes huérfanas y caché de build
docker image prune -f
docker builder prune -f

# 3. Reconstruir desde cero (sin caché)
docker-compose build --no-cache

# 4. Levantar los servicios
docker-compose up -d

# 5. Esperar a que Oracle esté listo (puede tardar ~30 segundos)
# Puedes verificar con: docker-compose logs oracle-db

# 6. Correr las migraciones
docker-compose exec web bundle exec rails db:migrate

# 7. Crear el ApiClient de prueba
docker-compose exec web bundle exec rails runner "ApiClient.create(name: 'Test App')"

# 8. Probar el endpoint
## Buscar por consola el ApiClient creado:
docker-compose exec web bundle exec rails console
ApiClient.last.api_key
ejemplo de api_key: 17d963077a6f57d1e2248cfc22c533345f9251f679865fffff26be10800498b3