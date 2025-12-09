# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

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
puts "📝 Seed data loaded successfully!"
