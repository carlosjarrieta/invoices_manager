module Clients
  module Entities
    class Client
      attr_reader :company_name, :nit, :email, :address

      def initialize(company_name:, nit:, email:, address:)
        @company_name = company_name
        @nit = nit
        @email = email
        @address = address
      end

      def valid?
        company_name.present? &&
          nit.present? &&
          email.present? &&
          address.present? &&
          valid_email_format?
      end

      private

      def valid_email_format?
        email.match?(URI::MailTo::EMAIL_REGEXP)
      end
    end
  end
end
