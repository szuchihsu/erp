require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @customer = customers(:retail_customer)
    @user = users(:admin_user)
    sign_in @user
  end

  test "should get index" do
    get customers_url
    assert_response :success
  end

  test "should get new" do
    get new_customer_url
    assert_response :success
  end

  test "should create customer" do
    assert_difference("Customer.count") do
      post customers_url, params: {
        customer: {
          customer_id: "CUST999",  # Use unique ID
          name: "Test Customer",
          email: "test@example.com",
          phone: "555-9999",
          address: "999 Test St",
          customer_type: "retail",
          status: "active"
        }
      }
    end

    assert_redirected_to customer_url(Customer.last)
  end

  test "should show customer" do
    get customer_url(@customer)
    assert_response :success
  end

  test "should get edit" do
    get edit_customer_url(@customer)
    assert_response :success
  end

  test "should update customer" do
    patch customer_url(@customer), params: {
      customer: {
        customer_id: @customer.customer_id,  # Keep same ID
        name: "Updated Customer Name",
        email: "updated@example.com",
        phone: @customer.phone,
        address: @customer.address,
        customer_type: @customer.customer_type,
        status: @customer.status
      }
    }
    assert_redirected_to customer_url(@customer)
  end

  test "should destroy customer" do
    # Use a customer without associations to allow deletion
    deletable_customer = customers(:inactive_customer)
    assert_difference("Customer.count", -1) do
      delete customer_url(deletable_customer)
    end

    assert_redirected_to customers_url
  end
end
