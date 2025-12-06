# frozen_string_literal: true

# ActivityLog - Polymorphic MongoDB model for tracking Oracle model events
#
# This model records all activities (create, update, delete) from ActiveRecord
# models (Oracle) for auditing and traceability purposes.
#
# Usage example:
#   ActivityLog.create!(
#     action: 'create',
#     loggable_type: 'Invoice',
#     loggable_id: 123,
#     user_id: current_user.id,
#     changes: { number: 'INV-001', total: 1000.00 },
#     metadata: { ip: request.remote_ip }
#   )
#
class ActivityLog
  include Mongoid::Document
  include Mongoid::Timestamps

  # Main fields
  field :action, type: String              # 'create', 'update', 'delete', 'custom'
  field :loggable_type, type: String       # Model name (e.g., 'Invoice', 'Customer')
  field :loggable_id, type: Integer        # Oracle record ID
  field :user_id, type: Integer            # User ID who performed the action
  field :user_email, type: String          # User email (for reference)

  # Change data
  field :changes, type: Hash, default: {}  # Changes made (before/after hash)
  field :metadata, type: Hash, default: {} # Additional info (IP, user agent, etc)

  # Context information
  field :controller, type: String          # Controller that executed the action
  field :endpoint, type: String            # Endpoint/route
  field :request_id, type: String          # Request ID for tracking

  # Validations
  validates :action, presence: true, inclusion: { in: %w[create update delete custom] }
  validates :loggable_type, presence: true
  validates :loggable_id, presence: true

  # Indexes for efficient querying
  index({ loggable_type: 1, loggable_id: 1 })
  index({ user_id: 1 })
  index({ action: 1 })
  index({ created_at: -1 })
  index({ loggable_type: 1, created_at: -1 })
  index({ request_id: 1 })

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :for_record, ->(type, id) { where(loggable_type: type, loggable_id: id) }
  scope :today, -> { where(:created_at.gte => Time.zone.now.beginning_of_day) }
  scope :this_week, -> { where(:created_at.gte => Time.zone.now.beginning_of_week) }
  scope :this_month, -> { where(:created_at.gte => Time.zone.now.beginning_of_month) }

  # Class methods
  class << self
    # Logs a record creation
    def log_create(record, user: nil, metadata: {})
      create!(
        action: 'create',
        loggable_type: record.class.name,
        loggable_id: record.id,
        user_id: user&.id,
        user_email: user&.email,
        changes: record.attributes,
        metadata: metadata
      )
    end

    # Logs a record update
    def log_update(record, user: nil, metadata: {})
      return unless record.saved_changes?

      create!(
        action: 'update',
        loggable_type: record.class.name,
        loggable_id: record.id,
        user_id: user&.id,
        user_email: user&.email,
        changes: {
          before: record.saved_changes.transform_values(&:first),
          after: record.saved_changes.transform_values(&:last)
        },
        metadata: metadata
      )
    end

    # Logs a record deletion
    def log_delete(record, user: nil, metadata: {})
      create!(
        action: 'delete',
        loggable_type: record.class.name,
        loggable_id: record.id,
        user_id: user&.id,
        user_email: user&.email,
        changes: record.attributes,
        metadata: metadata
      )
    end

    # Logs a custom action
    def log_custom(type, id, description, user: nil, metadata: {})
      create!(
        action: 'custom',
        loggable_type: type,
        loggable_id: id,
        user_id: user&.id,
        user_email: user&.email,
        changes: { description: description },
        metadata: metadata
      )
    end

    # Retrieves full history for a record
    def history_for(record)
      for_record(record.class.name, record.id).recent
    end
  end

  # Instance methods

  # Human-readable log description using I18n
  def description
    if action == 'custom'
      changes['description'] || I18n.t('activity_log.actions.custom', type: loggable_type, id: loggable_id)
    else
      I18n.t("activity_log.actions.#{action}", type: loggable_type, id: loggable_id)
    end
  end

  # Changed fields (update only)
  def changed_fields
    return [] unless action == 'update' && changes['before'].present?

    changes['before'].keys
  end

  # Get previous value of a field
  def previous_value(field)
    changes.dig('before', field.to_s)
  end

  # Get new value of a field
  def new_value(field)
    changes.dig('after', field.to_s)
  end

  # Check if a specific field changed
  def field_changed?(field)
    changed_fields.include?(field.to_s)
  end

  # JSON representation
  def as_json(options = {})
    super(options).merge(
      description: description,
      changed_fields: changed_fields
    )
  end
end
