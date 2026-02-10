require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with email and password" do
    user = User.new(email: "test@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid without password" do
    user = User.new(email: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "email must be unique (case-insensitive)" do
    user1 = User.create!(email: "test@example.com", password: "password123", password_confirmation: "password123")
    user2 = User.new(email: "TEST@EXAMPLE.COM", password: "password123", password_confirmation: "password123")
    assert_not user2.valid?
    assert_includes user2.errors[:email], "has already been taken"
  end

  test "email must have valid format" do
    user = User.new(email: "invalid-email", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "password must be at least 6 characters" do
    user = User.new(email: "test@example.com", password: "12345", password_confirmation: "12345")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "password confirmation must match" do
    user = User.new(email: "test@example.com", password: "password123", password_confirmation: "different")
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "accepts very long email addresses" do
    long_email = "#{'a' * 240}@example.com"  # 254 characters total
    user = User.new(email: long_email, password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "accepts very long passwords" do
    long_password = "a" * 128
    user = User.new(email: "test@example.com", password: long_password, password_confirmation: long_password")
    assert user.valid?
  end

  test "accepts special characters in email" do
    user = User.new(email: "test+tag@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end
end
