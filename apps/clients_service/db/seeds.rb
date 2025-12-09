# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🔐 Clients Service - Seed Data"
puts "=" * 50

# Create API Client for authentication
api_client = ApiClient.find_or_create_by!(name: 'Default API Client') do |client|
  client.api_key = SecureRandom.hex(32)
end

puts "✅ API Client created: #{api_client.name}"
puts "   ID:       #{api_client.id}"
puts "   API Key:  #{api_client.api_key}"
puts ""
puts "🔑 Para autenticarte usa CUALQUIERA de estos:"
puts "   1. {\"api_client_id\": #{api_client.id}}"
puts "   2. {\"api_key\": \"#{api_client.api_key}\"}"
puts ""

# Create sample clients
clients = [
  {
    company_name: 'Empresa Demo S.A.S',
    nit: '900123456-7',
    email: 'contacto@empresademo.com',
    address: 'Calle 123 #45-67, Bogotá'
  },
  {
    company_name: 'Tech Solutions Colombia',
    nit: '900234567-8',
    email: 'info@techsolutions.com',
    address: 'Carrera 11 #89-12, Medellín'
  },
  {
    company_name: 'Servicios Integrales Ltda',
    nit: '900345678-9',
    email: 'servicio@integral.com',
    address: 'Calle 50 #10-20, Cali',
  }
]

puts "📝 Creating sample clients..."
clients.each do |client_data|
  Client.find_or_create_by!(nit: client_data[:nit]) do |client|
    client.company_name = client_data[:company_name]
    client.email = client_data[:email]
    client.address = client_data[:address]
  end
  puts "   ✅ #{client_data[:company_name]}"
end

puts ""
puts "🔐 Para usar la API, genera un token JWT:"
puts "   rails console"
puts "   api_client = ApiClient.first"
puts "   token = JsonWebToken.encode(api_client_id: api_client.id)"
puts "   puts token"
puts ""
puts "=" * 50
puts "✨ Seed data loaded successfully!"