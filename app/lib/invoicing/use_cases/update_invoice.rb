module Invoicing
  module UseCases
    class UpdateInvoice
      def initialize(repository, audit_service, client_service)
        @repo = repository
        @audit_service = audit_service
        @client_service = client_service
      end

      def execute(invoice_id, params)
        invoice = ::Invoice.find_by(id: invoice_id)

        unless invoice
          @audit_service.log(I18n.t('api.audit.invoice_update_failed'),
                             { error: I18n.t('api.invoices.not_found'), invoice_id: invoice_id }, 'ERROR')
          return { status: :not_found, message: I18n.t('api.invoices.not_found') }
        end

        old_attributes = invoice.attributes.slice('amount', 'issue_date', 'client_id')

        # Update attributes safely
        invoice.amount = params[:amount] if params[:amount].present?
        begin
          invoice.issue_date = Date.parse(params[:issue_date].to_s) if params[:issue_date].present?
        rescue StandardError
          nil
        end

        # Validate Client if changing
        if params[:client_id].present? && params[:client_id].to_s != invoice.client_id.to_s
          unless @client_service.exists?(params[:client_id])
            @audit_service.log(I18n.t('api.audit.invoice_update_failed'),
                               { error: I18n.t('api.invoices.client_not_found'), client_id: params[:client_id], invoice_id: invoice.id }, 'ERROR')
            return { status: :unprocessable_entity, message: I18n.t('api.invoices.client_not_found') }
          end
          invoice.client_id = params[:client_id]
        end

        if invoice.save
          changes = {
            before: old_attributes,
            after: invoice.attributes.slice('amount', 'issue_date', 'client_id')
          }

          @audit_service.log(I18n.t('api.audit.invoice_updated'), { invoice_id: invoice.id, changes: changes },
                             'SUCCESS')
          { status: :ok, message: I18n.t('api.invoices.updated'), data: invoice }
        else
          @audit_service.log(I18n.t('api.audit.invoice_update_failed'), { error: invoice.errors.full_messages, invoice_id: invoice_id },
                             'ERROR')
          { status: :unprocessable_entity, message: invoice.errors.full_messages.join(', ') }
        end
      end
    end
  end
end
