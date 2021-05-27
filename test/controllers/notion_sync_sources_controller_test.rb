require "test_helper"

class NotionSyncSourcesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get notion_sync_sources_new_url
    assert_response :success
  end

  test "should get create" do
    get notion_sync_sources_create_url
    assert_response :success
  end

  test "should get destroy" do
    get notion_sync_sources_destroy_url
    assert_response :success
  end
end
