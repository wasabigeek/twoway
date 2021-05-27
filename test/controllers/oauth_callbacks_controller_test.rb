require "test_helper"

class OAuthCallbacksControllerTest < ActionDispatch::IntegrationTest
  test "should get notion" do
    get oauth_callbacks_notion_url
    assert_response :success
  end
end
