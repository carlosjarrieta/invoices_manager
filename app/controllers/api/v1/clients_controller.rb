# app/controllers/api/v1/clients_controller.rb
module Api
  module V1
    class ClientsController < ApplicationController
      before_action :set_client, only: [:show]

      # POST /api/v1/clients
      def create
        @client = Client.new(client_params)

        if @client.save
          # TODO: Audit Service Log here
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
        render json: { error: 'Client not found' }, status: :not_found
      end

      def client_params
        params.require(:client).permit(:name, :identification, :email, :address)
      end
    end
  end
end
