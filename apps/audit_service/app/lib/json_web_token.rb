class JsonWebToken
  # Use a shared secret key for inter-service JWT validation
  # All services must use the same key to validate tokens from each other
  SECRET_KEY = ENV['JWT_SECRET_KEY'] || Rails.application.secret_key_base.to_s

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end
end