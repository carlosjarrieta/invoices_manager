require 'test_helper'

module Clients
  module UseCases
    class CreateClientTest < ActiveSupport::TestCase
      def setup
        @repository = mock
        @audit_service = mock
        @use_case = CreateClient.new(@repository, @audit_service)
      end

      test 'should create client successfully' do
        params = {
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'test@example.com',
          address: 'Test Address'
        }

        @repository.expects(:save).returns(mock(id: 1, company_name: 'Test Company', nit: '123456789-0', email: 'test@example.com'))
        @audit_service.expects(:log).once

        result = @use_case.execute(params)

        assert_equal :ok, result[:status]
        assert result[:data].present?
      end

      test 'should fail with invalid email' do
        params = {
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'invalid-email',
          address: 'Test Address'
        }

        @audit_service.expects(:log).once

        result = @use_case.execute(params)

        assert_equal :error, result[:status]
        assert_equal I18n.t('api.clients.invalid_data'), result[:message]
      end

      test 'should fail with missing company_name' do
        params = {
          company_name: '',
          nit: '123456789-0',
          email: 'test@example.com',
          address: 'Test Address'
        }

        @audit_service.expects(:log).once

        result = @use_case.execute(params)

        assert_equal :error, result[:status]
        assert_equal I18n.t('api.clients.invalid_data'), result[:message]
      end

      test 'should fail when repository save fails' do
        params = {
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'test@example.com',
          address: 'Test Address'
        }

        @repository.expects(:save).returns(false)
        @audit_service.expects(:log).once

        result = @use_case.execute(params)

        assert_equal :error, result[:status]
        assert_equal I18n.t('api.clients.database_error'), result[:message]
      end
    end
  end
end
