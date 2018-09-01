require 'test_helper'

class UserTest < ActiveSupport::TestCase
    def setup
      @user = User.new(name: "Example User", email: "user@example.com")
    end

    test "should be valid" do
      assert @user.valid?
    end

    test "name should be present" do
      @user.name = ""
      assert_not @user.valid?
    end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "email addresses should be saved as lower-case" do
      mixed_case_email = "Foo@ExAMPle.CoM"
      @user.email = mixed_case_email
      @user.save
      assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "user should have default keytech_url and credentials" do
      #@user.save
      assert_equal 'https://demo.keytech.de', @user.keytech_url
      assert_equal 'jgrant', @user.keytech_username
      assert_equal '', @user.keytech_password
  end

end
