require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  setup do
    @customer = customers(:one)

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
    visit customers_url
    assert_selector "h1", text: "Customers"
  end

  test "should create customer" do
    visit customers_url
    click_on "New customer"

    fill_in "Address", with: @customer.address
    fill_in "Customer", with: @customer.customer_id
    fill_in "Customer type", with: @customer.customer_type
    fill_in "Email", with: @customer.email
    fill_in "Name", with: @customer.name
    fill_in "Phone", with: @customer.phone
    fill_in "Status", with: @customer.status
    click_on "Create Customer"

    assert_text "Customer was successfully created"
    click_on "Back"
  end

  test "should update Customer" do
    visit customer_url(@customer)
    click_on "Edit this customer", match: :first

    fill_in "Address", with: @customer.address
    fill_in "Customer", with: @customer.customer_id
    fill_in "Customer type", with: @customer.customer_type
    fill_in "Email", with: @customer.email
    fill_in "Name", with: @customer.name
    fill_in "Phone", with: @customer.phone
    fill_in "Status", with: @customer.status
    click_on "Update Customer"

    assert_text "Customer was successfully updated"
    click_on "Back"
  end

  test "should destroy Customer" do
    visit customer_url(@customer)
    accept_confirm { click_on "Destroy this customer", match: :first }

    assert_text "Customer was successfully destroyed"
  end
end
