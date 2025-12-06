class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :request_id
  attribute :user_agent
  attribute :ip_address
end
