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

  test "should have default keytech server and username" do
    user = User.new(email: "user@example.com", password: "crypted stuff")
    puts "Before save: keytechurl: #{user.keytech_url}"
    user.save
    puts "after save: keytechurl: #{user.keytech_url}"
    assert_not_empty user.keytech_url
    assert_not_empty user.keytech_username
  end

  test "should have always a lower case mail addresss" do
    user = User.new(email: "user@EXAMPLE.com", password: "crypted stuff")
    user.save
    assert_equal 'user@example.com', user.email
  end

end
