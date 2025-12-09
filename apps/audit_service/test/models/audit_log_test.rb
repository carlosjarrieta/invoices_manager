require 'test_helper'

class AuditLogTest < ActiveSupport::TestCase
  test 'should create audit log with valid attributes' do
    audit_log = AuditLog.create(
      action: 'user_login',
      entity: 'User',
      entity_id: '123',
      details: { ip: '127.0.0.1' },
      performed_by: 'test_user',
      ip_address: '127.0.0.1',
      status: 'SUCCESS'
    )

    assert audit_log.persisted?
    assert_equal 'user_login', audit_log.action
    assert_equal 'User', audit_log.entity
    assert_equal '123', audit_log.entity_id
    assert_equal({ 'ip' => '127.0.0.1' }, audit_log.details)
    assert_equal 'test_user', audit_log.performed_by
    assert_equal '127.0.0.1', audit_log.ip_address
    assert_equal 'SUCCESS', audit_log.status
  end

  test 'should have default status SUCCESS' do
    audit_log = AuditLog.create(
      action: 'test_action',
      entity: 'TestEntity',
      entity_id: '456'
    )

    assert_equal 'SUCCESS', audit_log.status
  end

  test 'should have timestamps' do
    audit_log = AuditLog.create(
      action: 'test_action',
      entity: 'TestEntity',
      entity_id: '456'
    )

    assert_not_nil audit_log.created_at
    assert_not_nil audit_log.updated_at
  end

  test 'should allow nil values for optional fields' do
    audit_log = AuditLog.create(
      action: 'test_action',
      entity: 'TestEntity'
    )

    assert audit_log.persisted?
    assert_nil audit_log.entity_id
    assert_nil audit_log.ip_address
    assert_equal({}, audit_log.details)
    assert_nil audit_log.performed_by
  end
end