module Invoicing
  module Infrastructure
    class AuditAdapter
      def initialize(ip_address)
        @ip_address = ip_address
      end

      def log(action, data, status = 'SUCCESS')
        # Try to get entity ID from available fields
        # Priority: id, invoice_id, then client_id (only if others missing)
        entity_id = data[:id] || data[:invoice_id] || data[:client_id]

        AuditService.log(
          action: action,
          entity: 'Invoice',
          entity_id: entity_id, # Can be nil initially
          details: data,
          ip_address: @ip_address,
          status: status
        )
      end
    end
  end
end
