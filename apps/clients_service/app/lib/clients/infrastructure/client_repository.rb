# frozen_string_literal: true

module Clients
  module Infrastructure
    class ClientRepository
      def save(client_entity)
        record = ::Client.new(
          company_name: client_entity.company_name,
          nit: client_entity.nit,
          email: client_entity.email,
          address: client_entity.address
        )

        return record if record.save

        false
      end

      def find_by_id(id)
        ::Client.find(id)
      rescue ActiveRecord::RecordNotFound
        nil
      end

      def find_by_nit(nit)
        ::Client.find_by(nit: nit)
      end

      def find_by_nit_flexible(nit_param)
        # Try exact match first
        client = ::Client.find_by(nit: nit_param)
        return client if client

        # If not found and NIT doesn't have hyphen, try adding wildcard for verification digit
        if !nit_param.include?('-')
          client = ::Client.where('nit LIKE ?', "#{nit_param}-%").first
          return client if client
        end

        # If still not found and NIT has hyphen, try without verification digit
        if nit_param.include?('-')
          base_nit = nit_param.split('-').first
          client = ::Client.where('nit LIKE ?', "#{base_nit}-%").first
          return client if client
        end

        nil
      end

      def all(page: 1, per_page: 10)
        offset = (page.to_i - 1) * per_page.to_i
        ::Client.offset(offset).limit(per_page.to_i)
      end

      def count
        ::Client.count
      end
    end
  end
end
