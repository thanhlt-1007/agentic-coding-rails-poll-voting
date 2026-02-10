# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Poll Creation Form Display", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    # Login
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end

  describe "form elements" do
    before do
      visit new_me_poll_path
    end

    it "displays the form title" do
      expect(page).to have_content("Create a New Poll")
    end

    it "displays question field with label" do
      expect(page).to have_field("Question")
      expect(page).to have_selector("label", text: "Question")
    end

    it "displays deadline field with label and help text" do
      expect(page).to have_field("poll_deadline")
      expect(page).to have_selector("label", text: /Deadline/)
      expect(page).to have_content("Set a deadline")
    end

    it "displays 4 answer fields with labels" do
      expect(page).to have_field("poll_answers_attributes_0_text")
      expect(page).to have_field("poll_answers_attributes_1_text")
      expect(page).to have_field("poll_answers_attributes_2_text")
      expect(page).to have_field("poll_answers_attributes_3_text")

      expect(page).to have_selector("label", text: "Option 1")
      expect(page).to have_selector("label", text: "Option 2")
      expect(page).to have_selector("label", text: "Option 3")
      expect(page).to have_selector("label", text: "Option 4")
    end

    it "displays submit button" do
      expect(page).to have_button("Create Poll")
    end

    it "has answer options header" do
      expect(page).to have_content("Answer Options")
    end

    it "has placeholders for question field" do
      question_field = find_field("Question")
      expect(question_field[:placeholder]).to be_present
    end

    it "has placeholders for answer fields" do
      answer_field = find_field("poll_answers_attributes_0_text")
      expect(answer_field[:placeholder]).to be_present
    end
  end

  describe "form styling" do
    before do
      visit new_me_poll_path
    end

    it "applies Tailwind classes to question field" do
      question_field = find_field("Question")
      expect(question_field[:class]).to include("border", "rounded-lg", "focus:ring")
    end

    it "applies Tailwind classes to deadline field" do
      deadline_field = find_field("poll_deadline")
      expect(deadline_field[:class]).to include("border", "rounded-lg", "focus:ring")
    end

    it "applies Tailwind classes to answer fields" do
      answer_field = find_field("poll_answers_attributes_0_text")
      expect(answer_field[:class]).to include("border", "rounded-lg", "focus:ring")
    end

    it "applies Tailwind classes to submit button" do
      submit_button = find_button("Create Poll")
      expect(submit_button[:class]).to include("bg-blue", "text-white", "rounded-lg")
    end
  end
end
