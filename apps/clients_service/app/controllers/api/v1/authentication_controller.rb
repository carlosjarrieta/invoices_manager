# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request!, if: :authenticate_action?

      # POST /api/v1/authenticate
      # Acepta: {"api_client_id": 1} o {"api_key": "..."}
      def create
        api_client = find_api_client

        if api_client
          token = JsonWebToken.encode(api_client_id: api_client.id)
          render json: {
            token: token,
            api_client: {
              id: api_client.id,
              name: api_client.name
            },
            expires_in: 24.hours.to_i
          }, status: :ok
        else
          render json: { error: 'API Client not found' }, status: :not_found
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end

      private

      def authenticate_action?
        action_name == 'create'
      end

      def find_api_client
        if params[:api_client_id].present?
          ApiClient.find(params[:api_client_id])
        elsif params[:api_key].present?
          ApiClient.find_by(api_key: params[:api_key])
        else
          nil
        end
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
  end
end
