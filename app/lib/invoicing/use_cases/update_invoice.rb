module Invoicing
  module UseCases
    class UpdateInvoice
      def initialize(repository, audit_service)
        @repo = repository
        @audit_service = audit_service
      end

      def execute(invoice_id, params)
        invoice = ::Invoice.find_by(id: invoice_id)

        unless invoice
          @audit_service.log('Invoice Update Failed', { error: 'Invoice not found', invoice_id: invoice_id }, 'ERROR')
          return { status: :not_found, message: I18n.t('api.invoices.not_found') }
        end

        old_attributes = invoice.attributes.slice('amount', 'issue_date')

        # Update attributes safely
        invoice.amount = params[:amount] if params[:amount].present?
        begin
          invoice.issue_date = Date.parse(params[:issue_date].to_s) if params[:issue_date].present?
        rescue StandardError
          nil
        end

        if invoice.save
          changes = {
            before: old_attributes,
            after: invoice.attributes.slice('amount', 'issue_date')
          }

          @audit_service.log('Invoice Updated', { invoice_id: invoice.id, changes: changes }, 'SUCCESS')
          { status: :ok, message: I18n.t('api.invoices.updated'), data: invoice }
        else
          @audit_service.log('Invoice Update Failed', { error: invoice.errors.full_messages, invoice_id: invoice_id },
                             'ERROR')
          { status: :unprocessable_entity, message: invoice.errors.full_messages.join(', ') }
        end
      end
    end
  end
end
