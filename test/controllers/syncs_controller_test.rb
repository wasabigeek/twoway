require "test_helper"

class SyncsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sync = syncs(:one)
  end

  test "should get index" do
    get syncs_url
    assert_response :success
  end

  test "should get new" do
    get new_sync_url
    assert_response :success
  end

  test "should create sync" do
    assert_difference('Sync.count') do
      post syncs_url, params: { sync: { user_id: @sync.user_id } }
    end

    assert_redirected_to sync_url(Sync.last)
  end

  test "should show sync" do
    get sync_url(@sync)
    assert_response :success
  end

  test "should get edit" do
    get edit_sync_url(@sync)
    assert_response :success
  end

  test "should update sync" do
    patch sync_url(@sync), params: { sync: { user_id: @sync.user_id } }
    assert_redirected_to sync_url(@sync)
  end

  test "should destroy sync" do
    assert_difference('Sync.count', -1) do
      delete sync_url(@sync)
    end

    assert_redirected_to syncs_url
  end
end
