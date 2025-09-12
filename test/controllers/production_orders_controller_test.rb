require "test_helper"

class ProductionOrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @production_order = production_orders(:corporate_bulk_production)
    @user = users(:admin_user)
    sign_in @user
  end

  test "should get index" do
    get production_orders_url
    assert_response :success
  end

  test "should get show" do
    get production_order_url(@production_order)
    assert_response :success
  end

  test "should get new" do
    get new_production_order_url
    assert_response :success
  end

  test "should create production_order" do
    assert_difference("ProductionOrder.count") do
      post production_orders_url, params: {
        production_order: {
          product_id: products(:diamond_ring).id,
          bill_of_material_id: bill_of_materials(:diamond_ring_bom).id,
          quantity: 1,
          priority: "normal",
          status: "pending",
          due_date: 1.month.from_now
        }
      }
    end

    assert_redirected_to production_order_url(ProductionOrder.last)
  end

  test "should get edit" do
    get edit_production_order_url(@production_order)
    assert_response :success
  end

  test "should update production_order" do
    patch production_order_url(@production_order), params: {
      production_order: {
        quantity: 2,
        notes: "Updated notes"
      }
    }
    assert_redirected_to production_order_url(@production_order)
  end

  test "should destroy production_order" do
    assert_difference("ProductionOrder.count", -1) do
      delete production_order_url(@production_order)
    end

    assert_redirected_to production_orders_url
  end

  test "should start production_order" do
    patch start_production_order_url(@production_order)
    assert_redirected_to production_order_url(@production_order)
  end

  test "should complete production_order" do
    patch complete_production_order_url(@production_order)
    assert_redirected_to production_order_url(@production_order)
  end
end
