require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test 'should be valid with valid attributes' do
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
      nit: '123456789-0',
      email: 'test@example.com',
      address: 'Test Address'
    )

    refute client.valid?
    assert_includes client.errors[:company_name], "can't be blank"
  end

  test 'should not be valid without nit' do
    client = Client.new(
      company_name: 'Test Company',
      email: 'test@example.com',
      address: 'Test Address'
    )

    refute client.valid?
    assert_includes client.errors[:nit], "can't be blank"
  end

  test 'should not be valid without email' do
    client = Client.new(
      company_name: 'Test Company',
      nit: '123456789-0',
      address: 'Test Address'
    )

    refute client.valid?
    assert_includes client.errors[:email], "can't be blank"
  end

  test 'should not be valid without address' do
    client = Client.new(
      company_name: 'Test Company',
      nit: '123456789-0',
      email: 'test@example.com'
    )

    refute client.valid?
    assert_includes client.errors[:address], "can't be blank"
  end

  test 'should not be valid with invalid email format' do
    client = Client.new(
      company_name: 'Test Company',
      nit: '123456789-0',
      email: 'invalid-email',
      address: 'Test Address'
    )

    refute client.valid?
    assert_includes client.errors[:email], 'is invalid'
  end

  # test 'should not allow duplicate nit' do
  #   Client.create!(
  #     company_name: 'Existing Company',
  #     nit: '123456789-0',
  #     email: 'existing@example.com',
  #     address: 'Existing Address'
  #   )

  #   client = Client.new(
  #     company_name: 'New Company',
  #     nit: '123456789-0',
  #     email: 'new@example.com',
  #     address: 'New Address'
  #   )

  #   refute client.valid?
  #   assert_includes client.errors[:nit], 'has already been taken'
  # end

  # test 'should not allow duplicate email' do
  #   Client.create!(
  #     company_name: 'Existing Company',
  #     nit: '123456789-0',
  #     email: 'test@example.com',
  #     address: 'Existing Address'
  #   )

  #   client = Client.new(
  #     company_name: 'New Company',
  #     nit: '987654321-0',
  #     email: 'test@example.com',
  #     address: 'New Address'
  #   )

  #   refute client.valid?
  #   assert_includes client.errors[:email], 'has already been taken'
  # end
end