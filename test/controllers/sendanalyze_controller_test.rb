require "test_helper"

class SendanalyzeControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get sendanalyze_create_url
    assert_response :success
  end
end
