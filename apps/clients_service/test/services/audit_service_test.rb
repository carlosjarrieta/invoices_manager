require 'test_helper'
require 'net/http'

class AuditServiceTest < ActiveSupport::TestCase
  setup do
    @uri = URI('http://audit_service:3000/api/v1/audit_logs')
    @http = mock
    @request = mock
    @response = mock
  end

  test 'should send audit log successfully' do
    Net::HTTP.expects(:new).with(@uri.host, @uri.port).returns(@http)
    @http.expects(:use_ssl=).with(false)
    @http.expects(:open_timeout=).with(2)
    @http.expects(:read_timeout=).with(5)

    Net::HTTP::Post.expects(:new).with(@uri.path, 'Content-Type' => 'application/json').returns(@request)
    @request.expects(:body=).with({
      action: 'test_action',
      entity: 'TestEntity',
      entity_id: '123',
      details: { key: 'value' },
      performed_by: 'TestUser',
      ip_address: '127.0.0.1',
      status: 'SUCCESS'
    }.to_json)

    @http.expects(:request).with(@request).returns(@response)
    @response.expects(:is_a?).with(Net::HTTPSuccess).returns(true)

    AuditService.log(
      action: 'test_action',
      entity: 'TestEntity',
      entity_id: '123',
      details: { key: 'value' },
      performed_by: 'TestUser',
      ip_address: '127.0.0.1',
      status: 'SUCCESS'
    )

    # Wait for the thread to finish
    sleep 0.1
  end

  test 'should log warning when response is not successful' do
    Rails.logger.expects(:warn).with('Audit Service returned 500: Error body')

    Net::HTTP.expects(:new).returns(@http)
    @http.expects(:use_ssl=)
    @http.expects(:open_timeout=)
    @http.expects(:read_timeout=)

    Net::HTTP::Post.expects(:new).returns(@request)
    @request.expects(:body=)

    @http.expects(:request).returns(@response)
    @response.expects(:is_a?).with(Net::HTTPSuccess).returns(false)
    @response.expects(:code).returns('500')
    @response.expects(:body).returns('Error body')

    AuditService.log(action: 'test_action', entity: 'TestEntity', entity_id: '123')

    sleep 0.1
  end

  test 'should log error when exception occurs' do
    Rails.logger.expects(:error).with('Failed to send audit log: Test error')

    Net::HTTP.expects(:new).raises(StandardError.new('Test error'))

    AuditService.log(action: 'test_action', entity: 'TestEntity', entity_id: '123')

    sleep 0.1
  end

  test 'should use default values when not provided' do
    Net::HTTP.expects(:new).returns(@http)
    @http.expects(:use_ssl=)
    @http.expects(:open_timeout=)
    @http.expects(:read_timeout=)

    Net::HTTP::Post.expects(:new).returns(@request)
    @request.expects(:body=).with({
      action: 'test_action',
      entity: 'TestEntity',
      entity_id: '123',
      details: {},
      performed_by: 'System',
      ip_address: nil,
      status: 'SUCCESS'
    }.to_json)

    @http.expects(:request).returns(@response)
    @response.expects(:is_a?).returns(true)

    AuditService.log(action: 'test_action', entity: 'TestEntity', entity_id: '123')

    sleep 0.1
  end
end