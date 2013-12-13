class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.integer :user_id
      t.integer :batch_id
      t.date :received_date
      t.string :fnsku
      t.string :sku
      t.text :product_name
      t.integer :quantity
      t.string :fba_shipment_id
      t.string :fulfillment_center_id
      t.integer :quantity_remaining

      t.timestamps
    end
    add_index :inventories, [:user_id, :received_date]
  end
end
