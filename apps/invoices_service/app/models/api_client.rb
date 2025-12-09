# frozen_string_literal: true

class ApiClient < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :api_key, presence: true, uniqueness: true

  before_validation :generate_api_key, on: :create

  private

  def generate_api_key
    self.api_key ||= SecureRandom.hex(32)
  end
end