# app/controllers/api/v1/clients_controller.rb
module Api
  module V1
    class ClientsController < ApplicationController
      include Authenticable
      before_action :set_client, only: [:show]

      # GET /api/v1/clients
      def index
        @clients = Client.all
        render json: { data: @clients }
      end

      # POST /api/v1/clients
      def create
        @client = Client.new(client_params)

        if @client.save
          AuditService.log(
            action: 'Client Created',
            entity: 'Client',
          AuditService.log('Client Created', { id: @client.id.to_s, name: @client.company_name, nit: @client.nit, email: @client.email }, 'SUCCESS')
          render json: { message: I18n.t('api.clients.created'), data: @client }, status: :created
        else
          AuditService.log('Client Creation Failed', { error: @client.errors.full_messages, params: client_params }, 'ERROR')
          render json: @client.errors, status: :unprocessable_content
        end
      end

      # GET /api/v1/clients/:id
      def show
        page = params[:page] || 1
        per_page = params[:per_page] || 10
        per_page = [per_page.to_i, 50].min

        # Get client invoices paginated
        invoices = @client.invoices.order(created_at: :desc)
                          .offset((page.to_i - 1) * per_page)
                          .limit(per_page)

        total_invoices = @client.invoices.count
        total_pages = (total_invoices.to_f / per_page).ceil

        render json: {
          data: @client.as_json.merge(
            invoices: {
              data: invoices,
              meta: {
                current_page: page.to_i,
                per_page: per_page.to_i,
                total_count: total_invoices,
                total_pages: total_pages
              }
            }
          )
        }
      end

      # GET /api/v1/clients/search_by_nit?nit=900123456-7
      def search_by_nit
        nit_param = params[:nit]

        # Try exact match first
        @client = Client.find_by(nit: nit_param)

        # If not found and NIT doesn't have hyphen, try adding wildcard for verification digit
        if @client.nil? && !nit_param.include?('-')
          # Search for NIT with any verification digit (e.g., 900123456-%)
          @client = Client.where('nit LIKE ?', "#{nit_param}-%").first
        end

        # If still not found and NIT has hyphen, try without verification digit
        if @client.nil? && nit_param.include?('-')
          # Remove verification digit and search (e.g., 900123456-7 -> 900123456-%)
          base_nit = nit_param.split('-').first
          @client = Client.where('nit LIKE ?', "#{base_nit}-%").first
        end

        if @client
          render json: @client
        else
          render json: { error: I18n.t('api.clients.not_found') }, status: :not_found
        end
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
