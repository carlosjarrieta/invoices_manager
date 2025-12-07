module Api
  module V1
    class InvoicesController < ApplicationController
      include Authenticable
      before_action :set_invoice, only: [:show]

      # Adapter to make our Rails AuditService compatible with the Clean Architecture Use Case interface
      class AuditAdapter
        def initialize(ip_address)
          @ip_address = ip_address
        end

        def log(action, data, status = 'SUCCESS')
          AuditService.log(
            action: action,
            entity: 'Invoice',
            entity_id: data[:client_id], # Ideally we'd have the invoice ID here
            details: data,
            ip_address: @ip_address,
            status: status
          )
        end
      end

      # POST /api/v1/invoices
      def create
        # 1. Initialize Infrastructure dependencies
        repository = Invoicing::Infrastructure::InvoiceRepository.new
        client_gateway = Invoicing::Infrastructure::ClientGateway.new

        # Use real Mongo Audit and inject Request IP
        audit_service = AuditAdapter.new(request.remote_ip)

        # 2. Initialize Use Case
        use_case = Invoicing::UseCases::CreateInvoice.new(repository, audit_service, client_gateway)

        # 3. Execute the logic
        # We extract strictly what we need from params
        input_params = {
          amount: params[:amount],
          client_id: params[:client_id]
        }

        result = use_case.execute(input_params)

        # 4. Return JSON response based on result
        if result[:status] == :ok
          render json: result, status: :created
        else
          render json: result, status: :unprocessable_entity
        end
      end

      # GET /api/v1/invoices/:id
      def show
        render json: { data: @invoice }
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
