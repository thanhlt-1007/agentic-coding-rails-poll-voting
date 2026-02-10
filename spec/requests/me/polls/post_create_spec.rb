# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /me/polls" do
  let(:user) { create(:user) }

  context "when user is authenticated" do
    before do
      sign_in user, scope: :user
    end

    context "with valid parameters" do
      let(:valid_params) do
        {
          poll: {
            question: "What is your favorite programming language?",
            deadline: 1.week.from_now,
            answers_attributes: {
              "0" => { text: "Ruby", position: 1 },
              "1" => { text: "Python", position: 2 },
              "2" => { text: "JavaScript", position: 3 },
              "3" => { text: "Go", position: 4 }
            }
          }
        }
      end

      it "creates a new poll" do
        expect {
          post me_polls_path, params: valid_params
        }.to change(Poll, :count).by(1)
      end

      it "creates 4 answers" do
        expect {
          post me_polls_path, params: valid_params
        }.to change(Answer, :count).by(4)
      end

      it "associates the poll with the current user" do
        post me_polls_path, params: valid_params
        poll = Poll.last
        expect(poll.user).to eq(user)
      end

      it "redirects to the poll show page" do
        post me_polls_path, params: valid_params
        poll = Poll.last
        expect(response).to redirect_to(me_poll_path(poll))
      end

      it "sets a success flash message" do
        post me_polls_path, params: valid_params
        follow_redirect!
        expect(response.body).to include("Poll was successfully created")
      end
    end

    context "with invalid parameters" do
      context "when question is blank" do
        let(:invalid_params) do
          {
            poll: {
              question: "",
              deadline: 1.week.from_now,
              answers_attributes: {
                "0" => { text: "A", position: 1 },
                "1" => { text: "B", position: 2 },
                "2" => { text: "C", position: 3 },
                "3" => { text: "D", position: 4 }
              }
            }
          }
        end

        it "does not create a poll" do
          expect {
            post me_polls_path, params: invalid_params
          }.not_to change(Poll, :count)
        end

        it "returns unprocessable entity status" do
          post me_polls_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "displays error messages" do
          post me_polls_path, params: invalid_params
          expect(response.body).to include("error")
        end
      end

      context "when answers count is not 4" do
        let(:invalid_params) do
          {
            poll: {
              question: "Test question?",
              deadline: 1.week.from_now,
              answers_attributes: {
                "0" => { text: "A", position: 1 },
                "1" => { text: "B", position: 2 },
                "2" => { text: "C", position: 3 }
              }
            }
          }
        end

        it "does not create a poll" do
          expect {
            post me_polls_path, params: invalid_params
          }.not_to change(Poll, :count)
        end

        it "returns unprocessable entity status" do
          post me_polls_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when answers are duplicate" do
        let(:invalid_params) do
          {
            poll: {
              question: "Test question?",
              deadline: 1.week.from_now,
              answers_attributes: {
                "0" => { text: "Same", position: 1 },
                "1" => { text: "same", position: 2 },
                "2" => { text: "Different", position: 3 },
                "3" => { text: "Other", position: 4 }
              }
            }
          }
        end

        it "does not create a poll" do
          expect {
            post me_polls_path, params: invalid_params
          }.not_to change(Poll, :count)
        end

        it "returns unprocessable entity status" do
          post me_polls_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when deadline is in the past" do
        let(:invalid_params) do
          {
            poll: {
              question: "Test question?",
              deadline: 1.day.ago,
              answers_attributes: {
                "0" => { text: "A", position: 1 },
                "1" => { text: "B", position: 2 },
                "2" => { text: "C", position: 3 },
                "3" => { text: "D", position: 4 }
              }
            }
          }
        end

        it "does not create a poll" do
          expect {
            post me_polls_path, params: invalid_params
          }.not_to change(Poll, :count)
        end

        it "returns unprocessable entity status" do
          post me_polls_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  context "when user is not authenticated" do
    let(:params) do
      {
        poll: {
          question: "Test?",
          deadline: 1.week.from_now,
          answers_attributes: {
            "0" => { text: "A", position: 1 },
            "1" => { text: "B", position: 2 },
            "2" => { text: "C", position: 3 },
            "3" => { text: "D", position: 4 }
          }
        }
      }
    end

    it "redirects to login page" do
      post me_polls_path, params: params
      expect(response).to redirect_to(new_user_session_path)
    end

    it "does not create a poll" do
      expect {
        post me_polls_path, params: params
      }.not_to change(Poll, :count)
    end
  end
end
