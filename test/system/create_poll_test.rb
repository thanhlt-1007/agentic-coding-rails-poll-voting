require "application_system_test_case"

class CreatePollTest < ApplicationSystemTestCase
  test "creating poll with valid data" do
    visit new_poll_url

    fill_in "Question", with: "What's your favorite programming language?"
    fill_in "Deadline", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
    
    # Fill in first two choices (minimum required)
    all("input[name*='[choices_attributes]'][name$='[text]']")[0].set("Ruby")
    all("input[name*='[choices_attributes]'][name$='[text]']")[1].set("Python")
    
    check "Show results while voting"

    click_button "Create Poll"

    assert_text "Poll was successfully created"
    assert_text "What's your favorite programming language?"
  end

  test "showing validation errors for invalid poll" do
    visit new_poll_url

    # Leave question blank
    fill_in "Question", with: ""
    fill_in "Deadline", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")

    click_button "Create Poll"

    assert_text "Question can't be blank"
  end
end
