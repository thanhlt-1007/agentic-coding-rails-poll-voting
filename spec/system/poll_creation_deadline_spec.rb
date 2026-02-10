# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Poll Creation Deadline", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    # Login
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end

  describe "deadline field" do
    it "allows creating a poll with a future deadline" do
      visit new_me_poll_path

      fill_in "Question", with: "What is your favorite color?"
      fill_in "poll_deadline", with: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")

      fill_in "poll_answers_attributes_0_text", with: "Red"
      fill_in "poll_answers_attributes_1_text", with: "Blue"
      fill_in "poll_answers_attributes_2_text", with: "Green"
      fill_in "poll_answers_attributes_3_text", with: "Yellow"

      expect {
        click_button "Create Poll"
      }.to change(Poll, :count).by(1)

      poll = Poll.last
      expect(poll.deadline).to be_present
      expect(poll.deadline).to be > Time.current
    end

    it "displays validation error for past deadline" do
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
      expect(Poll.count).to eq(0)
    end

    it "displays the deadline on the poll show page" do
      future_time = 1.week.from_now
      visit new_me_poll_path

      fill_in "Question", with: "What is your favorite framework?"
      fill_in "poll_deadline", with: future_time.strftime("%Y-%m-%dT%H:%M")

      fill_in "poll_answers_attributes_0_text", with: "Rails"
      fill_in "poll_answers_attributes_1_text", with: "Django"
      fill_in "poll_answers_attributes_2_text", with: "Express"
      fill_in "poll_answers_attributes_3_text", with: "Spring"

      click_button "Create Poll"

      expect(page).to have_content("Deadline:")
      expect(page).to have_content(future_time.strftime("%B"))
    end
  end
end
