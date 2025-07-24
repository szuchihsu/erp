require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get dashboard_url  # NOT dashboard_index_url
    assert_response :success
  end

  test "should get root" do
    get root_url  # Also works since root points to dashboard#index
    assert_response :success
  end
end
