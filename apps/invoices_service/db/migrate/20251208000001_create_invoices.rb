class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.integer :client_id, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :issue_date, null: false
      t.string :status, default: 'pending'
      t.text :notes

      t.timestamps
    end

    add_index :invoices, :client_id
    add_index :invoices, :issue_date
    add_index :invoices, :status
  end
end
