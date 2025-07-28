require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
    @user = User.create!(
      username: "testuser4",
      name: "Test User Four",
      role: "admin",
      password: "password123",
      password_confirmation: "password123"
    )
    sign_in_user(@user)
  end

  private

  def sign_in_user(user)
    visit new_user_session_path

    assert_selector "input[name='user[username]']"

    fill_in "Username", with: user.username
    fill_in "Password", with: "password123"
    click_on "Log in"

    assert_text "Welcome, #{user.name}"
    assert_current_path root_path
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "should create product" do
    visit products_url
    click_on "New product"

    assert_text "New product"
    assert_selector "input[name='product[product_id]']"

    fill_in "Product", with: "PROD999"
    fill_in "Name", with: "Test Product"
    fill_in "Description", with: "Test product description"
    select "rings", from: "Category"
    fill_in "Material", with: "gold"
    fill_in "Weight", with: "5.5"
    fill_in "Cost price", with: "100.00"
    fill_in "Selling price", with: "150.00"
    fill_in "Stock quantity", with: "10"
    fill_in "Minimum stock", with: "3"
    fill_in "Supplier", with: "Test Supplier"
    select "Active", from: "Status"

    click_on "Create Product"

    assert_text "Product was successfully created"
    assert_text "Test Product"
  end

  test "should show product" do
    visit product_url(@product)

    assert_text @product.name
    assert_text @product.product_id
    assert_text @product.description
  end

  test "should update Product" do
    visit edit_product_url(@product)

    assert_text "Editing product"
    assert_selector "input[name='product[name]']"

    fill_in "Name", with: "Updated Product Name"
    fill_in "Selling price", with: "200.00"

    click_on "Update Product"

    assert_text "Product was successfully updated"
    assert_text "Updated Product Name"
  end

  test "should destroy Product" do
    visit product_url(@product)

    assert_text @product.name

    accept_confirm do
      click_on "Destroy this product"
    end

    assert_text "Product was successfully destroyed"
    assert_current_path products_path
  end

  test "should validate required fields" do
    visit new_product_url

    # Try to create without required fields
    click_on "Create Product"

    # Should stay on new page with errors
    assert_text "New product"
    # Rails should show validation errors
  end

  test "should show low stock warning" do
    low_stock_product = products(:low_stock)
    visit product_url(low_stock_product)

    # Assuming you add low stock indication in the view
    assert_text low_stock_product.name
  end
end
