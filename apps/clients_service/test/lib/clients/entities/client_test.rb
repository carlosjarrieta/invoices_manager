require 'test_helper'

module Clients
  module Entities
    class ClientTest < ActiveSupport::TestCase
      test 'should initialize with valid attributes' do
        client = Client.new(
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'test@example.com',
          address: 'Test Address'
        )

        assert_equal 'Test Company', client.company_name
        assert_equal '123456789-0', client.nit
        assert_equal 'test@example.com', client.email
        assert_equal 'Test Address', client.address
      end

      test 'should be valid with all required attributes' do
        client = Client.new(
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'test@example.com',
          address: 'Test Address'
        )

        assert client.valid?
      end

      test 'should not be valid without company_name' do
        client = Client.new(
          company_name: '',
          nit: '123456789-0',
          email: 'test@example.com',
          address: 'Test Address'
        )

        refute client.valid?
      end

      test 'should not be valid without nit' do
        client = Client.new(
          company_name: 'Test Company',
          nit: '',
          email: 'test@example.com',
          address: 'Test Address'
        )

        refute client.valid?
      end

      test 'should not be valid without email' do
        client = Client.new(
          company_name: 'Test Company',
          nit: '123456789-0',
          email: '',
          address: 'Test Address'
        )

        refute client.valid?
      end

      test 'should not be valid without address' do
        client = Client.new(
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'test@example.com',
          address: ''
        )

        refute client.valid?
      end

      test 'should not be valid with invalid email format' do
        client = Client.new(
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'invalid-email',
          address: 'Test Address'
        )

        refute client.valid?
      end

      test 'should be valid with correct email format' do
        client = Client.new(
          company_name: 'Test Company',
          nit: '123456789-0',
          email: 'valid@example.com',
          address: 'Test Address'
        )

        assert client.valid?
      end
    end
  end
end
