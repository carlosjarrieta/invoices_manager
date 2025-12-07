module Api
  module V1
    class InvoicesController < ApplicationController

  # Temporary Stub for Audit Service (We will replace this later with real Mongo connection)
  class AuditServiceStub
    def log(action, data)
      Rails.logger.info "[AUDIT STUB] #{action}: #{data}"
    end
  end

  # POST /invoices
  def create
    # 1. Initialize Infrastructure dependencies
    # We use the Repository we just created for Oracle
    repository = Invoicing::Infrastructure::InvoiceRepository.new

    # We use the Stub/Fake audit service for now
    audit_service = AuditServiceStub.new

    # 2. Initialize the Use Case (Application Layer) with dependencies
    use_case = Invoicing::UseCases::CreateInvoice.new(repository, audit_service)

    # 3. Execute the logic
    # We extract strictly what we need from params
    input_params = {
      amount: params[:amount],
      client_id: params[:client_id]
    }

    result = use_case.execute(input_params)

    # 4. Return JSON response based on result
    if result[:status] == :ok
      render json: result, status: :created
    else
      render json: result, status: :unprocessable_entity
    end
  end
end
  end
end
