require 'test_helper'

module Invoicing
  module UseCases
    class CreateInvoiceTest < ActiveSupport::TestCase
      def setup
        @repository = mock
        @audit_service = mock
        @client_service = mock
        @use_case = CreateInvoice.new(@repository, @audit_service, @client_service)
      end

      test 'should create invoice successfully' do
        params = { amount: 2500000, client_id: 1, issue_date: '2025-12-09' }

        @client_service.expects(:exists?).with(1).returns(true)
        @repository.expects(:save).returns(mock(id: 1))
        @audit_service.expects(:log).twice

        result = @use_case.execute(params)

        assert_equal :ok, result[:status]
        assert result[:data].present?
      end

      test 'should fail with invalid date' do
        params = { amount: 1000, client_id: 1, issue_date: 'invalid-date' }

        @audit_service.expects(:log)

        result = @use_case.execute(params)

        assert_equal :error, result[:status]
        assert_equal I18n.t('api.invoices.invalid_date_format'), result[:message]
      end

      test 'should fail with invalid amount' do
        params = { amount: 0, client_id: 1 }

        @audit_service.expects(:log)

        result = @use_case.execute(params)

        assert_equal :error, result[:status]
        assert_equal I18n.t('api.invoices.invalid_data'), result[:message]
      end

      test 'should fail when client does not exist' do
        params = { amount: 1000, client_id: 999 }

        @client_service.expects(:exists?).with(999).returns(false)
        @audit_service.expects(:log)

        result = @use_case.execute(params)

        assert_equal :error, result[:status]
        assert_equal I18n.t('api.invoices.client_not_found'), result[:message]
      end

      test 'should fail when repository save fails' do
        params = { amount: 1000, client_id: 1 }

        @client_service.expects(:exists?).returns(true)
        @repository.expects(:save).returns(false)
        @audit_service.expects(:log).twice

        result = @use_case.execute(params)

        assert_equal :error, result[:status]
        assert_equal I18n.t('api.invoices.database_error'), result[:message]
      end
    end
  end
end