require 'test_helper'

class TodolistsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get todolists_index_url
    assert_response :success
  end

end
