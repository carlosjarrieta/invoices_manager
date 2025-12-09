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
      # Validate that the api_client_id exists in the database
      api_client = ApiClient.find_by(id: @decoded[:api_client_id])
      raise ActiveRecord::RecordNotFound unless api_client
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      render json: { errors: I18n.t('api.errors.unauthorized') }, status: :unauthorized
    end
  end
end