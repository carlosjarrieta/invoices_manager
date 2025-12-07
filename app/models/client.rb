class Client < ApplicationRecord
  # Validations
  validates :company_name, presence: true
  validates :nit, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address, presence: true

  has_many :invoices
end
