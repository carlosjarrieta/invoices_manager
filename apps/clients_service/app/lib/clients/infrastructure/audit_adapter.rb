module Clients
  module Infrastructure
    class AuditAdapter
      def initialize(ip_address = nil)
        @ip_address = ip_address
      end

      def log(action, details, status)
        AuditService.log(
          action: action,
          entity: 'Client',
          entity_id: details[:id]&.to_s,
          details: details,
          ip_address: @ip_address,
          status: status
        )
      end
    end
  end
end
