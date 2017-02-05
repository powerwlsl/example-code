require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get adminpanel" do
    get :adminpanel
    assert_response :success
  end

  test "should get faq" do
    get :faq
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get feedback" do
    get :feedback
    assert_response :success
  end

  test "should get press" do
    get :press
    assert_response :success
  end

  test "should get howitworks" do
    get :howitworks
    assert_response :success
  end

  test "should get careers" do
    get :careers
    assert_response :success
  end

  test "should get product" do
    get :product
    assert_response :success
  end

end
