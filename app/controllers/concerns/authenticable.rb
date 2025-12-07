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
      # You can fetch the current api client here if needed
      # @current_api_client = ApiClient.find(@decoded[:api_client_id])
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      render json: { errors: I18n.t('api.errors.unauthorized') }, status: :unauthorized
    end
  end
end
