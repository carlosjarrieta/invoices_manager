class CreateApiClients < ActiveRecord::Migration[7.1]
  def change
    create_table :api_clients do |t|
      t.string :name
      t.string :api_key

      t.timestamps
    end

    add_index :api_clients, :api_key, unique: true
  end
end
