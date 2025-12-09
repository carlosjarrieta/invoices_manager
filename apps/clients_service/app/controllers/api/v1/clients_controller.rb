module Api
  module V1
    class ClientsController < ApplicationController
      include Authenticable

      # GET /api/v1/clients
      def index
        repository = Clients::Infrastructure::ClientRepository.new

        page = params[:page] || 1
        per_page = params[:per_page] || 10
        per_page = [per_page.to_i, 100].min

        clients = repository.all(page: page, per_page: per_page)
        total_count = repository.count
        total_pages = (total_count.to_f / per_page).ceil

        render json: {
          data: clients,
          meta: {
            current_page: page.to_i,
            per_page: per_page.to_i,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      end

      # POST /api/v1/clients
      def create
        repository = Clients::Infrastructure::ClientRepository.new
        audit_service = Clients::Infrastructure::AuditAdapter.new(request.remote_ip)
        use_case = Clients::UseCases::CreateClient.new(repository, audit_service)

        result = use_case.execute(client_params)

        if result[:status] == :ok
          render json: { message: result[:message], data: result[:data] }, status: :created
        else
          render json: { error: result[:message] }, status: :unprocessable_content
        end
      end

      # GET /api/v1/clients/:id
      def show
        repository = Clients::Infrastructure::ClientRepository.new
        @client = repository.find_by_id(params[:id])

        if @client
          render json: { data: @client }
        else
          render json: { error: I18n.t('api.clients.not_found') }, status: :not_found
        end
      end

      # GET /api/v1/clients/search_by_nit?nit=900123456-7
      def search_by_nit
        repository = Clients::Infrastructure::ClientRepository.new
        @client = repository.find_by_nit_flexible(params[:nit])

        if @client
          render json: @client
        else
          render json: { error: I18n.t('api.clients.not_found') }, status: :not_found
        end
      end

      private

      def client_params
        params.require(:client).permit(:company_name, :nit, :email, :address)
      end
    end
  end
end