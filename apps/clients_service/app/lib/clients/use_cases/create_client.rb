# frozen_string_literal: true

module Clients
  module UseCases
    class CreateClient
      def initialize(repository, audit_service)
        @repo = repository
        @audit_service = audit_service
      end

      def execute(params)
        client = Entities::Client.new(
          company_name: params[:company_name],
          nit: params[:nit],
          email: params[:email],
          address: params[:address]
        )

        unless client.valid?
          @audit_service.log(
            I18n.t('api.audit.client_creation_failed'),
            { error: 'Invalid data', params: params },
            'ERROR'
          )
          return { status: :error, message: I18n.t('api.clients.invalid_data') }
        end

        result = @repo.save(client)

        unless result
          @audit_service.log(
            I18n.t('api.audit.client_creation_failed'),
            { error: 'Database error', params: params },
            'ERROR'
          )
          return { status: :error, message: I18n.t('api.clients.database_error') }
        end

        @audit_service.log(
          I18n.t('api.audit.client_created'),
          { id: result.id, name: result.company_name, nit: result.nit, email: result.email },
          'SUCCESS'
        )

        { status: :ok, message: I18n.t('api.clients.created'), data: result }
      end
    end
  end
end
