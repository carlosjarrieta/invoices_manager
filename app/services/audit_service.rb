class AuditService
  def self.log(action:, entity:, entity_id:, details: {}, performed_by: 'System', ip_address: nil, status: 'SUCCESS')
    Thread.new do
      AuditLog.create!(
        action: action,
        entity: entity,
        entity_id: entity_id,
        details: details,
        performed_by: performed_by,
        ip_address: ip_address,
        status: status
      )
    rescue StandardError => e
      Rails.logger.error "Audit Log Failed: #{e.message}"
    end
  end
end
