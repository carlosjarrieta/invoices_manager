# app/lib/invoicing/infrastructure/client_gateway.rb
module Invoicing
  module Infrastructure
    class ClientGateway
      # In a real distributed microservices world, this would make an HTTP GET request
      # to the Clients Service.
      # Since we are in a modular monolith, we query ActiveRecord directly but keep it decoupled.
      def exists?(client_id)
        ::Client.exists?(client_id)
      end
    end
  end
end
