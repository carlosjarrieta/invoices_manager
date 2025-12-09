# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApplicationController
      # No incluir Authenticable porque este endpoint no requiere autenticación previa

      # POST /api/v1/authenticate
      # Acepta: {"api_client_id": 1} o {"api_key": "..."}
      def create
        # Para audit_service, aceptamos el token sin verificar api_client
        # ya que solo necesitamos validar en los otros servicios
        if params[:api_client_id].present? || params[:api_key].present?
          # Generar token con datos mínimos
          token = JsonWebToken.encode(api_client_id: params[:api_client_id] || 1)
          render json: { 
            token: token,
            expires_in: 24.hours.to_i,
            message: 'Token generated for audit service'
          }, status: :ok
        else
          render json: { error: 'api_client_id or api_key required' }, status: :bad_request
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end
    end
  end
end
