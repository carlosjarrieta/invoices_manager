# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create API Client for authentication
api_client = ApiClient.find_or_create_by!(name: 'Default API Client') do |client|
  client.api_key = 'your-secret-api-key-here'
end

puts "API Client created: #{api_client.name} (API Key: #{api_client.api_key})"

puts "Seed data loaded successfully!"
puts "Note: Invoices should be created via the API after clients are available from the Clients Service"
