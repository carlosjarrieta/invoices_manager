require 'net/http'
require 'json'

module Invoicing
  module Infrastructure
    class AuditAdapter
      def initialize(ip_address)
        @ip_address = ip_address
      end

      def log(action, data, status = 'SUCCESS')
        entity_id = data[:id] || data[:invoice_id] || data[:client_id]

        payload = {
          action: action,
          entity: 'Invoice',
          entity_id: entity_id,
          details: data,
          ip_address: @ip_address,
          status: status
        }

        # Fire and forget (Pseudo-async)
        Thread.new do
          uri = URI("#{ENV['AUDIT_SERVICE_URL'] || 'http://localhost:3003'}/api/v1/audit_logs")
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
          request.body = payload.to_json
          http.request(request)
        rescue StandardError
          # Sentry.capture_exception(e)
        end
      end
    end
  end
end
