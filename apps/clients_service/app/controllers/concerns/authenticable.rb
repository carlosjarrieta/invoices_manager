module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    begin
      @decoded = JsonWebToken.decode(token)
      ApiClient.find(@decoded[:api_client_id])
    rescue StandardError => e
      render json: { errors: 'Unauthorized' }, status: :unauthorized
    end
  end
end
