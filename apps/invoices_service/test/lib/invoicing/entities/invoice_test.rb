require 'test_helper'

module Invoicing
  module Entities
    class InvoiceTest < ActiveSupport::TestCase
      test 'should initialize with valid attributes' do
        invoice = Invoice.new(amount: 1000.0, client_id: 1, issue_date: Date.today)

        assert_equal 1000.0, invoice.amount
        assert_equal 1, invoice.client_id
        assert_equal Date.today, invoice.issue_date
      end

      test 'should be valid with positive amount and present client_id' do
        invoice = Invoice.new(amount: 500.0, client_id: 2)

        assert invoice.valid?
      end

      test 'should not be valid with zero amount' do
        invoice = Invoice.new(amount: 0, client_id: 1)

        refute invoice.valid?
      end

      test 'should not be valid with negative amount' do
        invoice = Invoice.new(amount: -100.0, client_id: 1)

        refute invoice.valid?
      end

      test 'should not be valid without client_id' do
        invoice = Invoice.new(amount: 100.0, client_id: nil)

        refute invoice.valid?
      end

      test 'should use current time as default issue_date' do
        freeze_time do
          invoice = Invoice.new(amount: 100.0, client_id: 1)

          assert_equal Time.current, invoice.issue_date
        end
      end
    end
  end
end