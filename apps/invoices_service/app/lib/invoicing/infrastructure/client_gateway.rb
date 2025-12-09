require 'net/http'
require 'json'

module Invoicing
  module Infrastructure
    class ClientGateway
      def initialize
        @clients_service_url = ENV['CLIENTS_SERVICE_URL'] || 'http://localhost:3001'
        @token = generate_token
      end

      def exists?(client_id)
        # Using HTTP to communicate with Clients Service with JWT authentication
        url = URI("#{@clients_service_url}/api/v1/clients/#{client_id}")

        begin
          http = Net::HTTP.new(url.host, url.port)
          request = Net::HTTP::Get.new(url.path)
          request['Authorization'] = "Bearer #{@token}"
          
          response = http.request(request)
          response.is_a?(Net::HTTPSuccess)
        rescue StandardError => e
          # In a real app, log calling error
          Rails.logger.error "ClientGateway error: #{e.message}"
          false
        end
      end

      private

      def generate_token
        # Generate JWT token using the same method as controllers
        api_client_id = 1  # Default API Client ID
        JsonWebToken.encode(api_client_id: api_client_id)
      end
    end
  end
end
