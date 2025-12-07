```ruby
module Api
  module V1
    class InvoicesController < ApplicationController
      include Authenticable

      # Adapter to make our Rails AuditService compatible with the Clean Architecture Use Case interface
      class AuditAdapter
        def log(action, data)
          # Map Clean Arch params to our Service params
          # The Use Case sends (action, data hash)
          # We assume data contains entity info if needed, or we log generic
          AuditService.log(
            action: action,
            entity: 'Invoice',
            entity_id: data[:client_id], # Ideally we'd have the invoice ID here, but Use Case returns it after. Let's start basic.
            details: data
          )
        end
      end

      # POST /api/v1/invoices
      def create
        # 1. Initialize Infrastructure dependencies
        # We use      # 1. Initialize Infrastructure dependencies
      repository = Invoicing::Infrastructure::InvoiceRepository.new
      client_gateway = Invoicing::Infrastructure::ClientGateway.new
      
      # Use real Mongo Audit
      audit_service = AuditAdapter.new

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
    end
  end
end
