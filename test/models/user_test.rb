require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should not save a user without email and password" do
    user = User.new
    user.valid?
    # puts "#{user.errors.inspect}"
    assert_not user.valid?
  end

  test "should save a user without password" do
    user = User.new(email: "user@example.com")
    user.valid?
    # puts "#{user.errors.inspect}"
    assert_not user.valid?
  end

  test "should save a user with email and password" do
    user = User.new(email: "user@example.com", password: "crypted stuff")
    user.valid?
    # puts "#{user.errors.inspect}"
    assert user.valid?
  end

  test "should have readable keytech credentials after save" do
    user = User.new(email: "user@example.com", password: "crypted stuff")
    puts "Before save: keytech_url= #{user.keytech_url}"
    user.save
    id = user.id

    loaded_user = User.find(id)
    puts "After save: keytech_url= #{loaded_user.keytech_url}"
    assert_equal loaded_user.keytech_url, ENV['KEYTECH_URL']
    assert_equal loaded_user.keytech_username, ENV['KEYTECH_USERNAME']
  end

  test "should have always a lower case mail addresss" do
    user = User.new(email: "user@EXAMPLE.com", password: "crypted stuff")
    user.save
    assert_equal 'user@example.com', user.email
  end

end
