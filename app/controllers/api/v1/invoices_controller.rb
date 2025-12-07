module Api
  module V1
    class InvoicesController < ApplicationController
      include Authenticable
      before_action :set_invoice, only: [:show]

      # GET /api/v1/invoices?page=1&per_page=10&start_date=2023-01-01&end_date=2023-12-31
      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 10
        per_page = [per_page.to_i, 100].min

        query = Invoice.includes(:client).order(created_at: :desc)

        start_date = if params[:start_date].present?
                       Date.parse(params[:start_date])
                     else
                       Date.current
                     end

        end_date = if params[:end_date].present?
                     Date.parse(params[:end_date])
                   else
                     Date.current
                   end

        query = query.where(created_at: start_date.beginning_of_day..end_date.end_of_day)

        invoices = query.offset((page.to_i - 1) * per_page).limit(per_page)

        total_count = query.count
        total_pages = (total_count.to_f / per_page).ceil

        render json: {
          data: invoices.as_json(include: {
                                   client: { only: %i[id company_name email] }
                                 }),
          meta: {
            current_page: page.to_i,
            per_page: per_page.to_i,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      end

      # POST /api/v1/invoices
      def create
        # 1. Initialize Infrastructure dependencies
        repository = Invoicing::Infrastructure::InvoiceRepository.new
        client_gateway = Invoicing::Infrastructure::ClientGateway.new

        # Use real Mongo Audit and inject Request IP
        # Now using the extracted Infrastructure class
        audit_service = Invoicing::Infrastructure::AuditAdapter.new(request.remote_ip)

        # 2. Initialize Use Case
        use_case = Invoicing::UseCases::CreateInvoice.new(repository, audit_service, client_gateway)

        # 3. Execute the logic
        # We extract strictly what we need from params
        input_params = {
          amount: params[:amount],
          client_id: params[:client_id],
          issue_date: params[:issue_date]
        }

        result = use_case.execute(input_params)

        # 4. Return JSON response based on result
        if result[:status] == :ok
          # Include client data in the response
          result[:data] = result[:data].as_json(include: :client)
          render json: result, status: :created
        else
          render json: result, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/invoices/:id
      def update
        repository = Invoicing::Infrastructure::InvoiceRepository.new
        audit_service = Invoicing::Infrastructure::AuditAdapter.new(request.remote_ip)
        client_gateway = Invoicing::Infrastructure::ClientGateway.new

        use_case = Invoicing::UseCases::UpdateInvoice.new(repository, audit_service, client_gateway)

        result = use_case.execute(params[:id], params)

        if result[:status] == :ok
          render json: result, status: :ok
        elsif result[:status] == :not_found
          render json: { error: result[:message] }, status: :not_found
        else
          render json: { error: result[:message] }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/invoices/:id
      def show
        render json: { data: @invoice.as_json(include: :client) }
      end

      private

      def set_invoice
        @invoice = Invoice.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: I18n.t('api.invoices.not_found') }, status: :not_found
      end
    end
  end
end
