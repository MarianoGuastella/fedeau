require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(username: "test_user", password: "password123")
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "username should be present" do
    @user.username = nil
    assert_not @user.valid?
    assert_includes @user.errors[:username], "can't be blank"
  end

  test "username should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:username], "has already been taken"
  end

  test "password should be present" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "should authenticate with correct password" do
    @user.save
    assert @user.authenticate("password123")
  end

  test "should not authenticate with incorrect password" do
    @user.save
    assert_not @user.authenticate("wrongpassword")
  end

  test "password_digest should be present" do
    @user.password_digest = nil
    assert_not @user.valid?
  end
end
