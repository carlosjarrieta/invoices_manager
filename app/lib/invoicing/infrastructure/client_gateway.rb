module Invoicing
  module Infrastructure
    class ClientGateway
      def exists?(client_id)
        ::Client.exists?(client_id)
      end
    end
  end
end
