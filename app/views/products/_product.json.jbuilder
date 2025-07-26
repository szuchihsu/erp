json.extract! product, :id, :product_id, :name, :description, :category, :material, :weight, :cost_price, :selling_price, :stock_quantity, :minimum_stock, :supplier, :status, :created_at, :updated_at
json.url product_url(product, format: :json)
