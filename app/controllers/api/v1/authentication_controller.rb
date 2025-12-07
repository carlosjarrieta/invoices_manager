module Api
  module V1
    class AuthenticationController < ApplicationController
      def login
        api_client = ApiClient.find_by(api_key: params[:api_key])

        if api_client
          token = JsonWebToken.encode(api_client_id: api_client.id)
          render json: { token: token }, status: :ok
        else
          render json: { error: I18n.t('api.authentication.invalid_api_key') }, status: :unauthorized
        end
      end
    end
  end
end
