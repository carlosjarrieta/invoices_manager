require 'net/http'
require 'json'

module Invoicing
  module Infrastructure
    class ClientGateway
      def initialize
        @clients_service_url = ENV['CLIENTS_SERVICE_URL'] || 'http://clients_service:3000'
      end

      def exists?(client_id)
        token = generate_token
        url = URI("#{@clients_service_url}/api/v1/clients/#{client_id}")

        begin
          http = Net::HTTP.new(url.host, url.port)
          http.read_timeout = 5

          request = Net::HTTP::Get.new(url.path)
          request['Authorization'] = "Bearer #{token}"
          request['Content-Type'] = 'application/json'

          response = http.request(request)
          response.is_a?(Net::HTTPSuccess)
        rescue StandardError => e
          Rails.logger.error "ClientGateway error checking client #{client_id}: #{e.class} - #{e.message}"
          false
        end
      end

      private

      def generate_token
        api_client_id = 1 # Default API Client ID
        JsonWebToken.encode(api_client_id: api_client_id)
      end
    end
  end
end
