# app/controllers/api/v1/clients_controller.rb
module Api
  module V1
    class ClientsController < ApplicationController
      include Authenticable
      before_action :set_client, only: [:show]

      # POST /api/v1/clients
      def create
        @client = Client.new(client_params)

        if @client.save
          AuditService.log(
            action: 'Client Created',
            entity: 'Client',
            entity_id: @client.id,
            details: @client.as_json,
            performed_by: 'API' # We could extract ApiClient name here if available
          )
          render json: @client, status: :created
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      end

      # GET /api/v1/clients/:id
      def show
        render json: @client
      end

      private

      def set_client
        @client = Client.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: I18n.t('api.clients.not_found') }, status: :not_found
      end

      def client_params
        params.require(:client).permit(:company_name, :nit, :email, :address)
      end
    end
  end
end
