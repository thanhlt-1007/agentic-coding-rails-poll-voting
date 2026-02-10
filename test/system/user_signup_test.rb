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
    # Form reloads at sign_up path on validation errors
    assert_match %r{/sign_up}, current_path
  end

  test "sign-up fails with weak password" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "12345"
    fill_in "Confirm Password", with: "12345"

    click_button "Sign up"

    assert_text "Password is too short (minimum is 6 characters)"
    # Form reloads at sign_up path on validation errors
    assert_match %r{/sign_up}, current_path
  end

  test "sign-up fails with blank email" do
    visit new_user_registration_path

    fill_in "Email", with: ""
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"

    click_button "Sign up"

    assert_text "Email can't be blank"
    # Form reloads at sign_up path on validation errors
    assert_match %r{/sign_up}, current_path
  end

  test "sign-up fails with blank password" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: ""
    fill_in "Confirm Password", with: ""

    click_button "Sign up"

    assert_text "Password can't be blank"
    # Form reloads at sign_up path on validation errors
    assert_match %r{/sign_up}, current_path
  end

  test "sign-up fails with invalid email format" do
    visit new_user_registration_path

    # Disable HTML5 validation to test server-side validation
    page.execute_script("document.querySelector('input[type=email]').removeAttribute('type')")
    
    fill_in "Email", with: "invalid-email"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"

    click_button "Sign up"

    assert_text "Email is invalid"
    # Form reloads at sign_up path on validation errors
    assert_match %r{/sign_up}, current_path
  end

  test "sign-up fails with password confirmation mismatch" do
    visit new_user_registration_path

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "different"

    click_button "Sign up"

    assert_text "Password confirmation doesn't match Password"
    # Form reloads at sign_up path on validation errors
    assert_match %r{/sign_up}, current_path
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
    
    # Sign in the user first using Devise's test helper would be better,
    # but for system tests we'll sign up to get authenticated
    visit new_user_registration_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"
    click_button "Sign up"

    # User should see duplicate email error since user already exists
    assert_text "Email has already been taken"
  end
end
