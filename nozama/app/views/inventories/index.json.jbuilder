json.array!(@inventories) do |inventory|
  json.extract! inventory, 
  json.url inventory_url(inventory, format: :json)
end
