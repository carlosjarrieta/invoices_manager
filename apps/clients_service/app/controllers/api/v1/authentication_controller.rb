# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request!, if: :authenticate_action?

      # POST /api/v1/authenticate
      def create
        api_client = ApiClient.find(params[:api_client_id])
        
        if api_client
          token = JsonWebToken.encode(api_client_id: api_client.id)
          render json: { 
            token: token,
            api_client: api_client,
            expires_in: 24.hours.to_i
          }, status: :ok
        else
          render json: { error: 'API Client not found' }, status: :not_found
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'API Client not found' }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end

      private

      def authenticate_action?
        action_name == 'create'
      end
    end
  end
end
