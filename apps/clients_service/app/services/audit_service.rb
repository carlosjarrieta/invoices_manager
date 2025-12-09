# frozen_string_literal: true

require 'net/http'
require 'json'

# Service to communicate with Audit Service via HTTP
class AuditService
  AUDIT_SERVICE_URL = ENV.fetch('AUDIT_SERVICE_URL', 'http://localhost:3003')

  def self.log(action:, entity:, entity_id:, details: {}, performed_by: 'System', ip_address: nil, status: 'SUCCESS')
    Thread.new do
      begin
        uri = URI("#{AUDIT_SERVICE_URL}/api/v1/audit_logs")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.open_timeout = 2
        http.read_timeout = 5

        request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        request.body = {
          action: action,
          entity: entity,
          entity_id: entity_id&.to_s,
          details: details,
          performed_by: performed_by,
          ip_address: ip_address,
          status: status
        }.to_json

        response = http.request(request)
        
        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.warn "Audit Service returned #{response.code}: #{response.body}"
        end
      rescue StandardError => e
        Rails.logger.error "Failed to send audit log: #{e.message}"
      end
    end
  end
end
