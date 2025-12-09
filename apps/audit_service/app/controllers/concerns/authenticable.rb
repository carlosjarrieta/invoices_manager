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
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      render json: { errors: I18n.t('api.errors.unauthorized') }, status: :unauthorized
    end
  end
end
