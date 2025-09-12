require "test_helper"

class SalesOrderItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @sales_order_item = sales_order_items(:engagement_ring_item)
    @sales_order = @sales_order_item.sales_order
    @user = users(:admin_user)
    sign_in @user
  end

  test "should get new" do
    get new_sales_order_sales_order_item_url(@sales_order)
    assert_response :success
  end

  test "should create sales_order_item" do
    assert_difference("SalesOrderItem.count") do
      post sales_order_sales_order_items_url(@sales_order), params: {
        sales_order_item: {
          product_id: @sales_order_item.product_id,
          quantity: @sales_order_item.quantity,
          specifications: @sales_order_item.specifications,
          unit_price: @sales_order_item.unit_price
        }
      }
    end

    assert_redirected_to sales_order_url(@sales_order)
  end

  test "should get edit" do
    get edit_sales_order_sales_order_item_url(@sales_order, @sales_order_item)
    assert_response :success
  end

  test "should update sales_order_item" do
    patch sales_order_sales_order_item_url(@sales_order, @sales_order_item), params: {
      sales_order_item: {
        quantity: 2,
        specifications: "Updated specifications"
      }
    }
    assert_redirected_to sales_order_url(@sales_order)
  end

  test "should destroy sales_order_item" do
    assert_difference("SalesOrderItem.count", -1) do
      delete sales_order_sales_order_item_url(@sales_order, @sales_order_item)
    end

    assert_redirected_to sales_order_url(@sales_order)
  end
end
