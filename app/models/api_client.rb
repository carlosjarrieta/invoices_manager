class ApiClient < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :api_key, presence: true, uniqueness: true

  # Auto-generate API Key on creation if not present
  before_validation :generate_api_key, on: :create

  # Audit creation
  after_create :audit_creation

  private

  def generate_api_key
    self.api_key ||= SecureRandom.hex(32)
  end

  def audit_creation
    AuditService.log(
      action: 'ApiClient Created',
      entity: 'ApiClient',
      entity_id: id.to_s,
      details: { name: name },
      performed_by: 'System/Console'
    )
  end
end
