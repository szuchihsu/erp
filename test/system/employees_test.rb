require "application_system_test_case"

class EmployeesTest < ApplicationSystemTestCase
  setup do
    @employee = employees(:one)

    # Create user with proper password
    @user = User.create!(
      username: "testuser3",
      name: "Test User Three",
      role: "admin",
      password: "password123",
      password_confirmation: "password123"
    )

    sign_in_user(@user)
  end

  private

  def sign_in_user(user)
    visit new_user_session_path
    fill_in "Username", with: user.username
    fill_in "Password", with: "password123"
    click_on "Log in"

    # Debug: Check if login was successful
    assert_no_text "Invalid username or password"
  end

  test "visiting the index" do
    visit employees_url
    assert_selector "h1", text: "Employees"
  end

  test "should create employee" do
    visit employees_url
    click_on "New employee"

    # Use unique values to avoid conflicts
    fill_in "Employee", with: "EMP999"
    fill_in "Name", with: "Test Employee"
    fill_in "Email", with: "test@example.com"
    fill_in "Phone", with: "555-0123"
    select "production", from: "Department"
    fill_in "Position", with: "tester"
    fill_in "Hire date", with: Date.current.strftime("%Y-%m-%d")
    fill_in "Salary", with: "40000"
    select "active", from: "Status"

    click_on "Create Employee"

    assert_text "Employee was successfully created"
  end

  test "should update Employee" do
    visit employee_url(@employee)
    click_on "Edit this employee", match: :first

    fill_in "Name", with: "Updated Employee Name"
    fill_in "Email", with: "updated@example.com"
    click_on "Update Employee"

    assert_text "Employee was successfully updated"
  end

  test "should destroy Employee" do
    visit employee_url(@employee)

    # For Turbo confirmations, use page.accept_confirm
    page.accept_confirm do
      click_on "Destroy this employee"
    end

    assert_text "Employee was successfully destroyed"
  end
end
