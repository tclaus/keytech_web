require 'test_helper'

class StartPageTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'can see the welcome page' do
    get '/'
    assert_select 'h1', 'PLM Web'
  end

  test 'can see the login page' do
    get '/login'
    assert_select 'h1', 'PLM Web'
  end

  # Extend fpr static pages
  test 'can login' do
    sign_in users(:host)
    get '/'
    # Assert that the navbar shows the name of loggen in user
    assert_select '#navbarDropdown', users(:host).email
  end
end
