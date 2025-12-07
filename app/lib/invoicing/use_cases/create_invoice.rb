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
          @audit_service.log('Invoice Creation Failed', { error: 'Invalid data', amount: invoice.amount }, 'ERROR')
          return { status: :error, message: 'Invalid data: Amount must be positive and client valid' }
        end

        # Verify Client Existence (Cross-Boundary check)
        unless @client_service.exists?(invoice.client_id)
          @audit_service.log('Invoice Creation Failed', { error: 'Client not found', client_id: invoice.client_id },
                             'ERROR')
          return { status: :error, message: 'Client not found' }
        end

        # Persist using the repository (Infrastructure layer)
        result = @repo.save(invoice)

        unless result
          @audit_service.log('Invoice Creation Failed', { error: 'Database error', client_id: invoice.client_id },
                             'ERROR')
          return { status: :error, message: 'Database error' }
        end

        # Async Audit Log - Success
        @audit_service.log('Invoice Created', { client_id: invoice.client_id, amount: invoice.amount }, 'SUCCESS')
        { status: :ok, message: 'Invoice created successfully', data: result }
      end
    end
  end
end
