require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @product = products(:diamond_ring)
    @user = User.create!(
      username: "testuser",
      name: "Test User",
      role: "admin",
      password: "password123",
      password_confirmation: "password123"
    )
    sign_in @user
  end

  test "should get index" do
    get products_url
    assert_response :success
    assert_select "h1", "Products"
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: {
        product: {
          product_id: "PROD999",
          name: "Test Product",
          description: "Test description",
          category: "rings",
          material: "gold",
          weight: 10.0,
          cost_price: 100.0,
          selling_price: 150.0,
          stock_quantity: 5,
          minimum_stock: 2,
          supplier: "Test Supplier",
          status: "active"
        }
      }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: {
      product: {
        name: "Updated Product Name",
        selling_price: 200.0
      }
    }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    # Create a product without dependencies for deletion test
    test_product = Product.create!(
      product_id: "TEST-DELETE-001",
      name: "Test Product for Deletion",
      description: "Temporary product for testing deletion",
      selling_price: 100.00,
      status: "active"
    )

    assert_difference("Product.count", -1) do
      delete product_url(test_product)
    end

    assert_redirected_to products_url
  end

  test "should not create product with invalid data" do
    assert_no_difference("Product.count") do
      post products_url, params: {
        product: {
          product_id: "", # Invalid - blank
          name: "",       # Invalid - blank
          cost_price: -100 # Invalid - negative
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
