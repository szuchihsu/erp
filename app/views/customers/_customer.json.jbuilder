json.extract! customer, :id, :customer_id, :name, :email, :phone, :address, :customer_type, :status, :created_at, :updated_at
json.url customer_url(customer, format: :json)
