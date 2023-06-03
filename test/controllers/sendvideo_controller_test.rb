require "test_helper"

class SendvideoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sendvideo_index_url
    assert_response :success
  end
end
