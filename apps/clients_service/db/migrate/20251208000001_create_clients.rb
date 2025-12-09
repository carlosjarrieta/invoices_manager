class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :company_name, null: false
      t.string :nit, null: false
      t.string :email, null: false
      t.string :address, null: false
      t.string :phone

      t.timestamps
    end

    add_index :clients, :nit, unique: true
    add_index :clients, :email, unique: true
  end
end
