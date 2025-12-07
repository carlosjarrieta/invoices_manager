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
        # 1. Parse and Validate Issue Date
        issue_date = nil
        begin
          issue_date = if params[:issue_date].present?
                         Date.parse(params[:issue_date].to_s)
                       else
                         Date.current
                       end
        rescue Date::Error, TypeError
          @audit_service.log('Invoice Creation Failed',
                             { error: 'Invalid issue_date format', received: params[:issue_date] }, 'ERROR')
          return { status: :error, message: I18n.t('api.invoices.invalid_date_format') }
        end

        invoice = Entities::Invoice.new(
          amount: params[:amount].to_f,
          client_id: params[:client_id],
          issue_date: issue_date
        )

        unless invoice.valid?
          @audit_service.log('Invoice Creation Failed', { error: 'Invalid data', amount: invoice.amount }, 'ERROR')
          return { status: :error, message: I18n.t('api.invoices.invalid_data') }
        end

        # Verify Client Existence (Cross-Boundary check)
        unless @client_service.exists?(invoice.client_id)
          @audit_service.log('Invoice Creation Failed', { error: 'Client not found', client_id: invoice.client_id },
                             'ERROR')
          return { status: :error, message: I18n.t('api.invoices.client_not_found') }
        end

        # Persist using the repository (Infrastructure layer)
        result = @repo.save(invoice)

        unless result
          @audit_service.log('Invoice Creation Failed', { error: 'Database error', client_id: invoice.client_id },
                             'ERROR')
          return { status: :error, message: I18n.t('api.invoices.database_error') }
        end

        # Async Audit Log - Success
        @audit_service.log('Invoice Created', { id: result.id, client_id: invoice.client_id, amount: invoice.amount },
                           'SUCCESS')
        { status: :ok, message: I18n.t('api.invoices.created'), data: result }
      end
    end
  end
end
