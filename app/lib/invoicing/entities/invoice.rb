module Invoicing
  module Entities
    class Invoice
      attr_reader :amount, :client_id, :issue_date

      def initialize(amount:, client_id:, issue_date: Time.current)
        @amount = amount
        @client_id = client_id
        @issue_date = issue_date
      end

      # Business Logic: Validation
      def valid?
        @amount > 0 && @client_id.present?
      end
    end
  end
end
