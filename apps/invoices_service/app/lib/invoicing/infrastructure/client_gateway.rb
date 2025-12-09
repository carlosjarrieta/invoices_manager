require 'net/http'
require 'json'

module Invoicing
  module Infrastructure
    class ClientGateway
      def exists?(client_id)
        # Using HTTP to communicate with Clients Service
        base_url = ENV['CLIENTS_SERVICE_URL'] || 'http://localhost:3001'
        url = URI("#{base_url}/api/v1/clients/#{client_id}")

        begin
          response = Net::HTTP.get_response(url)
          response.is_a?(Net::HTTPSuccess)
        rescue StandardError
          # In a real app, log calling error
          false
        end
      end
    end
  end
end
