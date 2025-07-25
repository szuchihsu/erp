require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:one)
    @user = users(:one)
    sign_in @user # Sign in before each test
  end

  test "should get index" do
    get employees_url
    assert_response :success
  end

  test "should get new" do
    get new_employee_url
    assert_response :success
  end

  test "should create employee" do
    assert_difference("Employee.count") do
      post employees_url, params: {
        employee: {
          department: "production",
          email: "new@example.com",
          employee_id: "EMP999", # Use unique ID
          hire_date: "2024-01-01",
          name: "New Employee",
          phone: "555-0123",
          position: "tester",
          salary: 40000.00,
          status: "active",
          supervisor_id: nil
        }
      }
    end

    assert_redirected_to employee_url(Employee.last)
  end

  test "should show employee" do
    get employee_url(@employee)
    assert_response :success
  end

  test "should get edit" do
    get edit_employee_url(@employee)
    assert_response :success
  end

  test "should update employee" do
    patch employee_url(@employee), params: {
      employee: {
        department: @employee.department,
        email: "updated@example.com", # Change email to avoid conflicts
        employee_id: @employee.employee_id,
        hire_date: @employee.hire_date,
        name: "Updated Name",
        phone: @employee.phone,
        position: @employee.position,
        salary: @employee.salary,
        status: @employee.status,
        supervisor_id: @employee.supervisor_id
      }
    }
    assert_redirected_to employee_url(@employee)
  end

  test "should destroy employee" do
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee)
    end

    assert_redirected_to employees_url
  end
end
