json.extract! sales_order, :id, :order_id, :customer_id, :employee_id, :order_date, :delivery_date, :quotation_amount, :total_amount, :deposit_amount, :remaining_amount, :order_status, :notes, :created_at, :updated_at
json.url sales_order_url(sales_order, format: :json)
