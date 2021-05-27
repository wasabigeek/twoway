require "test_helper"

class SyncSourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sync_source = sync_sources(:one)
  end

  test "should get index" do
    get sync_sources_url
    assert_response :success
  end

  test "should get new" do
    get new_sync_source_url
    assert_response :success
  end

  test "should create sync_source" do
    assert_difference('SyncSource.count') do
      post sync_sources_url, params: { sync_source: { calendar_source_id: @sync_source.calendar_source_id, sync_id: @sync_source.sync_id } }
    end

    assert_redirected_to sync_source_url(SyncSource.last)
  end

  test "should show sync_source" do
    get sync_source_url(@sync_source)
    assert_response :success
  end

  test "should get edit" do
    get edit_sync_source_url(@sync_source)
    assert_response :success
  end

  test "should update sync_source" do
    patch sync_source_url(@sync_source), params: { sync_source: { calendar_source_id: @sync_source.calendar_source_id, sync_id: @sync_source.sync_id } }
    assert_redirected_to sync_source_url(@sync_source)
  end

  test "should destroy sync_source" do
    assert_difference('SyncSource.count', -1) do
      delete sync_source_url(@sync_source)
    end

    assert_redirected_to sync_sources_url
  end
end
