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


end
