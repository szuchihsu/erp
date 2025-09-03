require "test_helper"

class DesignRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get design_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get design_requests_show_url
    assert_response :success
  end

  test "should get new" do
    get design_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get design_requests_create_url
    assert_response :success
  end

  test "should get edit" do
    get design_requests_edit_url
    assert_response :success
  end

  test "should get update" do
    get design_requests_update_url
    assert_response :success
  end

  test "should get approve" do
    get design_requests_approve_url
    assert_response :success
  end

  test "should get reject" do
    get design_requests_reject_url
    assert_response :success
  end

  test "should get assign" do
    get design_requests_assign_url
    assert_response :success
  end
end
