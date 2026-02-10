# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Poll Creation Validation", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    # Login
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end

  describe "validation errors" do
    it "displays error for blank question" do
      visit new_me_poll_path

      fill_in "Question", with: ""
      fill_in "poll_deadline", with: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")

      fill_in "poll_answers_attributes_0_text", with: "Answer 1"
      fill_in "poll_answers_attributes_1_text", with: "Answer 2"
      fill_in "poll_answers_attributes_2_text", with: "Answer 3"
      fill_in "poll_answers_attributes_3_text", with: "Answer 4"

      click_button "Create Poll"

      expect(page).to have_content("error")
      expect(page).to have_current_path(me_polls_path)
      expect(Poll.count).to eq(0)
    end

    it "displays error for duplicate answers" do
      visit new_me_poll_path

      fill_in "Question", with: "What is your favorite color?"
      fill_in "poll_deadline", with: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")

      fill_in "poll_answers_attributes_0_text", with: "Blue"
      fill_in "poll_answers_attributes_1_text", with: "blue"
      fill_in "poll_answers_attributes_2_text", with: "Red"
      fill_in "poll_answers_attributes_3_text", with: "Green"

      click_button "Create Poll"

      expect(page).to have_content("error")
      expect(page).to have_content("Answer options must be unique")
      expect(page).to have_current_path(me_polls_path)
      expect(Poll.count).to eq(0)
    end

    it "displays error for question too short" do
      visit new_me_poll_path

      fill_in "Question", with: "Hi?"
      fill_in "poll_deadline", with: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")

      fill_in "poll_answers_attributes_0_text", with: "Answer 1"
      fill_in "poll_answers_attributes_1_text", with: "Answer 2"
      fill_in "poll_answers_attributes_2_text", with: "Answer 3"
      fill_in "poll_answers_attributes_3_text", with: "Answer 4"

      click_button "Create Poll"

      expect(page).to have_content("error")
      expect(page).to have_content("too short")
      expect(page).to have_current_path(me_polls_path)
      expect(Poll.count).to eq(0)
    end

    it "displays error for past deadline" do
      visit new_me_poll_path

      fill_in "Question", with: "What is your favorite programming language?"
      fill_in "poll_deadline", with: 1.day.ago.strftime("%Y-%m-%dT%H:%M")

      fill_in "poll_answers_attributes_0_text", with: "Ruby"
      fill_in "poll_answers_attributes_1_text", with: "Python"
      fill_in "poll_answers_attributes_2_text", with: "JavaScript"
      fill_in "poll_answers_attributes_3_text", with: "Go"

      click_button "Create Poll"

      expect(page).to have_content("error")
      expect(page).to have_content("must be in the future")
      expect(page).to have_current_path(me_polls_path)
      expect(Poll.count).to eq(0)
    end
  end
end
