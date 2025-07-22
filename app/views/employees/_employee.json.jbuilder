json.extract! employee, :id, :employee_id, :name, :email, :phone, :department, :position, :hire_date, :salary, :status, :supervisor_id, :created_at, :updated_at
json.url employee_url(employee, format: :json)
