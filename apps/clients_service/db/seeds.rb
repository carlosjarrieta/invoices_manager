# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create API Client for authentication
api_client = ApiClient.find_or_create_by!(name: 'Default API Client') do |client|
  client.api_key = 'your-secret-api-key-here'
end

puts "API Client created: #{api_client.name} (API Key: #{api_client.api_key})"

# Create sample clients
clients = [
  {
    company_name: 'Empresa Demo S.A.S',
    nit: '900123456-7',
    email: 'contacto@empresademo.com',
    address: 'Calle 123 #45-67, Bogotá',
    phone: '3001234567'
  },
  {
    company_name: 'Tech Solutions Colombia',
    nit: '800987654-3',
    email: 'info@techsolutions.co',
    address: 'Carrera 15 #88-22, Medellín',
    phone: '3009876543'
  }
]

clients.each do |client_data|
  Client.find_or_create_by!(nit: client_data[:nit]) do |client|
    client.company_name = client_data[:company_name]
    client.email = client_data[:email]
    client.address = client_data[:address]
    client.phone = client_data[:phone]
  end
  puts "Client created: #{client_data[:company_name]}"
end

puts "Seed data loaded successfully!"
