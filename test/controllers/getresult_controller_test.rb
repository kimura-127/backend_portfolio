require "test_helper"

class GetresultControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get getresult_index_url
    assert_response :success
  end
end
