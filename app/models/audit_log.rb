# app/models/audit_log.rb
class AuditLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :action, type: String
  field :entity, type: String
  field :entity_id, type: String
  field :details, type: Hash
  field :performed_by, type: String # To store basic info about usage

  # Index for faster queries
  index({ created_at: -1 })
  index({ entity: 1, entity_id: 1 })
end
