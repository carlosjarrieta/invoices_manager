class AuditService
  def self.log(action:, entity:, entity_id:, details: {}, performed_by: 'System')
    Thread.new do
      AuditLog.create!(
        action: action,
        entity: entity,
        entity_id: entity_id.to_s,
        details: details,
        performed_by: performed_by
      )
    rescue StandardError => e
      Rails.logger.error "[AuditService] Failed to log to Mongo: #{e.message}"
    end
  end
end
