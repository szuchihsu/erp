json.extract! sales_order_item, :id, :sales_order_id, :product_id, :quantity, :unit_price, :total_price, :specifications, :created_at, :updated_at
json.url sales_order_item_url(sales_order_item, format: :json)
