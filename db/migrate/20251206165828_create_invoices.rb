class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.integer :client_id
      t.decimal :amount, precision: 15, scale: 2
      t.datetime :issue_date

      t.timestamps
    end
  end
end
