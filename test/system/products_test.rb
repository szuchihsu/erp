require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "should create product" do
    visit products_url
    click_on "New product"

    fill_in "Category", with: @product.category
    fill_in "Cost price", with: @product.cost_price
    fill_in "Description", with: @product.description
    fill_in "Material", with: @product.material
    fill_in "Minimum stock", with: @product.minimum_stock
    fill_in "Name", with: @product.name
    fill_in "Product", with: @product.product_id
    fill_in "Selling price", with: @product.selling_price
    fill_in "Status", with: @product.status
    fill_in "Stock quantity", with: @product.stock_quantity
    fill_in "Supplier", with: @product.supplier
    fill_in "Weight", with: @product.weight
    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  test "should update Product" do
    visit product_url(@product)
    click_on "Edit this product", match: :first

    fill_in "Category", with: @product.category
    fill_in "Cost price", with: @product.cost_price
    fill_in "Description", with: @product.description
    fill_in "Material", with: @product.material
    fill_in "Minimum stock", with: @product.minimum_stock
    fill_in "Name", with: @product.name
    fill_in "Product", with: @product.product_id
    fill_in "Selling price", with: @product.selling_price
    fill_in "Status", with: @product.status
    fill_in "Stock quantity", with: @product.stock_quantity
    fill_in "Supplier", with: @product.supplier
    fill_in "Weight", with: @product.weight
    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  test "should destroy Product" do
    visit product_url(@product)
    accept_confirm { click_on "Destroy this product", match: :first }

    assert_text "Product was successfully destroyed"
  end
end
