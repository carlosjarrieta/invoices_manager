# app/lib/invoicing/use_cases/create_invoice.rb
module Invoicing
  module UseCases
    class CreateInvoice
      def initialize(invoice_repository, audit_service, client_service)
        @repo = invoice_repository
        @audit_service = audit_service
        @client_service = client_service
      end

      def execute(params)
        invoice = Entities::Invoice.new(
          amount: params[:amount].to_f,
          client_id: params[:client_id]
        )

        unless invoice.valid?
          return { status: :error, message: 'Invalid data: Amount must be positive and client valid' }
        end

        # Verify Client Existence (Cross-Boundary check)
        return { status: :error, message: 'Client not found' } unless @client_service.exists?(invoice.client_id)

        # Persist using the repository (Infrastructure layer)
        result = @repo.save(invoice)

        return { status: :error, message: 'Database error' } unless result

        # Async Audit Log
        @audit_service.log('Invoice Created', { client_id: invoice.client_id, amount: invoice.amount })
        { status: :ok, message: 'Invoice created successfully', data: result }
      end
    end
  end
end
