module Invoicing
  module Infrastructure
    class InvoiceRepository
      def save(invoice_entity)
        record = ::Invoice.new(
          client_id: invoice_entity.client_id,
          amount: invoice_entity.amount,
          issue_date: invoice_entity.issue_date
        )

        return record if record.save

        false
      end
    end
  end
end
