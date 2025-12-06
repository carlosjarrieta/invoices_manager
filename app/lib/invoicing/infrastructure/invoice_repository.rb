module Invoicing
  module Infrastructure
    class InvoiceRepository
      # Receives a Domain Entity (Invoicing::Entities::Invoice)
      # Returns true if successful, false otherwise
      def save(invoice_entity)
        # Convert Domain Entity to ActiveRecord Model
        record = ::Invoice.new(
          client_id: invoice_entity.client_id,
          amount: invoice_entity.amount,
          issue_date: invoice_entity.issue_date
        )

        # Persist to Oracle via ActiveRecord
        return record if record.save

        # Return the persisted record (truthy)

        false
      end
    end
  end
end
