# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Poll Creation Authentication", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  describe "unauthenticated access" do
    it "redirects to login when accessing new poll page" do
      visit new_poll_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe "authenticated access" do
    before do
      # Manual login for system specs
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
    end

    it "allows access to poll creation page" do
      visit new_poll_path
      expect(page).to have_current_path(new_poll_path)
      expect(page).to have_content("Create a New Poll")
    end

    it "allows poll creation" do
      visit new_poll_path

      fill_in "Question", with: "What is your favorite color?"
      fill_in "poll_deadline", with: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")

      fill_in "poll_answers_attributes_0_text", with: "Red"
      fill_in "poll_answers_attributes_1_text", with: "Blue"
      fill_in "poll_answers_attributes_2_text", with: "Green"
      fill_in "poll_answers_attributes_3_text", with: "Yellow"

      expect {
        click_button "Create Poll"
      }.to change(Poll, :count).by(1)

      expect(page).to have_content("Poll was successfully created")
      expect(page).to have_content("What is your favorite color?")
    end
  end
end
