require 'test_helper'

class StartPageTest < ActionDispatch::IntegrationTest

  test "can see the welcome page" do
    get "/"
    assert_select "h1", "PLM Web"
  end

  test "can see the login page" do
    get "/login"
    assert_select "h1", "PLM Web"
  end
  # Extend fpr static pages
end
