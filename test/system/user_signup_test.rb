require "application_system_test_case"

class UserSignupTest < ApplicationSystemTestCase
  test "successful sign-up with valid credentials" do
    visit new_user_registration_path

    fill_in "Email", with: "newuser@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"

    click_button "Sign up"

    assert_text "Welcome! You have signed up successfully."
    assert_current_path root_path
  end

  test "sign-up fails with duplicate email" do
    # Create existing user
    User.create!(email: "existing@example.com", password: "password123", password_confirmation: "password123")

    visit new_user_registration_path

    fill_in "Email", with: "existing@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"

    click_button "Sign up"

    assert_text "Email has already been taken"
    assert_current_path user_registration_path
  end

  test "sign-up fails with weak password" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "12345"
    fill_in "Confirm Password", with: "12345"

    click_button "Sign up"

    assert_text "Password is too short (minimum is 6 characters)"
    assert_current_path user_registration_path
  end

  test "sign-up fails with blank email" do
    visit new_user_registration_path

    fill_in "Email", with: ""
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"

    click_button "Sign up"

    assert_text "Email can't be blank"
    assert_current_path user_registration_path
  end

  test "sign-up fails with blank password" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: ""
    fill_in "Confirm Password", with: ""

    click_button "Sign up"

    assert_text "Password can't be blank"
    assert_current_path user_registration_path
  end

  test "sign-up fails with invalid email format" do
    visit new_user_registration_path

    fill_in "Email", with: "invalid-email"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"

    click_button "Sign up"

    assert_text "Email is invalid"
    assert_current_path user_registration_path
  end

  test "sign-up fails with password confirmation mismatch" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "different"

    click_button "Sign up"

    assert_text "Password confirmation doesn't match Password"
    assert_current_path user_registration_path
  end

  test "navigation from sign-up to login page" do
    visit new_user_registration_path

    click_link "Log in"

    assert_current_path new_user_session_path
  end

  test "sign-up page displays all required fields" do
    visit new_user_registration_path

    assert_selector "label", text: "Email"
    assert_selector "label", text: "Password"
    assert_selector "label", text: "Confirm Password"
    assert_button "Sign up"
  end

  test "authenticated user accessing sign-up redirects to root" do
    user = User.create!(email: "existing@example.com", password: "password123", password_confirmation: "password123")
    
    visit new_user_registration_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"
    click_button "Sign up"

    # User is now signed in, try to access sign-up again
    visit new_user_registration_path

    # Devise redirects authenticated users away from sign-up
    assert_current_path root_path
  end
end
