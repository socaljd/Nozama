class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.integer :user_id
      t.integer :batch_id
      t.integer :item_id
      t.integer :days_in_inventory
      t.date :shipment_date
      t.string :sku
      t.string :fnsku
      t.string :asin
      t.string :fulfillment_center_id
      t.integer :quantity
      t.string :amazon_order_id
      t.string :currency
      t.decimal :item_price_per_unit, :precision => 10, :scale => 2
      t.decimal :shipping_price, :precision => 10, :scale => 2
      t.decimal :gift_wrap_price, :precision => 10, :scale => 2
      t.string :ship_city
      t.string :ship_state
      t.string :ship_postal_code

      t.timestamps
    end
    add_index :sales, [:user_id, :shipment_date]
  end
end
