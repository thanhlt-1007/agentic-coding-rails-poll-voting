# Quickstart Guide - Poll Creation Feature

**Feature**: Poll Creation  
**Branch**: `002-create-poll`  
**Date**: February 11, 2026

## Prerequisites

- Ruby 3.3+ installed
- Rails 8.1.2+ installed
- PostgreSQL 14+ installed and running
- Git configured
- Existing user authentication system (from specs/001-user-signup)

## Development Setup

### 1. Clone and Branch

```bash
# Navigate to project directory
cd /path/to/agentic-coding-rails-poll-voting

# Fetch latest changes
git fetch --all

# Checkout the poll creation feature branch
git checkout 002-create-poll

# Verify you're on the correct branch
git branch --show-current
# Should output: 002-create-poll
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Verify Rails version
rails --version
# Should be: Rails 8.1.2

# Verify PostgreSQL connection
rails db:version
```

### 3. Database Setup

```bash
# Create databases if not exists
rails db:create

# Run existing migrations (from specs/001-user-signup)
rails db:migrate

# Load seed data (if any)
rails db:seed

# Verify database state
rails db:schema:dump
```

### 4. Run Existing Tests

```bash
# Run all existing tests to ensure baseline is green
bundle exec rspec

# Should see: 94 examples, 0 failures
# If any failures, fix before proceeding with poll creation
```

### 5. Verify RuboCop Compliance

```bash
# Run RuboCop on existing code
bin/rubocop

# Should see: 52 files inspected, no offenses detected
# If any offenses, fix before proceeding
```

## Implementing Poll Creation (TDD Workflow)

### Phase 1: Model Layer (Poll + Answer)

#### Step 1: Create Poll Model Spec

```bash
# Create model spec file
mkdir -p spec/models
touch spec/models/poll_spec.rb
```

**File**: `spec/models/poll_spec.rb`

```ruby
require "rails_helper"

RSpec.describe Poll, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:question) }
    
    it "requires exactly 4 answers" do
      poll = build(:poll, answers_attributes: [
        { text: "A", position: 1 },
        { text: "B", position: 2 },
        { text: "C", position: 3 }
      ])
      expect(poll).not_to be_valid
    end
  end
end
```

#### Step 2: Run Test (Red)

```bash
bundle exec rspec spec/models/poll_spec.rb
# Should fail: uninitialized constant Poll
```

#### Step 3: Generate Poll Model

```bash
# Generate Poll model with migration
rails generate model Poll user:references question:text deadline:datetime

# This creates:
# - app/models/poll.rb
# - db/migrate/[timestamp]_create_polls.rb
# - spec/models/poll_spec.rb (RSpec auto-generated)
# - spec/factories/polls.rb (FactoryBot auto-generated)
```

#### Step 4: Customize Poll Migration

Edit `db/migrate/[timestamp]_create_polls.rb`:

```ruby
class CreatePolls < ActiveRecord::Migration[8.1]
  def change
    create_table :polls do |t|
      t.references :user, null: false, foreign_key: true
      t.text :question, null: false
      t.datetime :deadline

      t.timestamps
    end

    add_index :polls, :created_at
    add_index :polls, :deadline
  end
end
```

#### Step 5: Run Migration

```bash
rails db:migrate
rails db:test:prepare  # Ensure test database is updated
```

#### Step 6: Implement Poll Model

**File**: `app/models/poll.rb`

```ruby
class Poll < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy
  accepts_nested_attributes_for :answers, reject_if: :all_blank

  validates :question, presence: true, length: { minimum: 5, maximum: 500 }
  validates :answers, length: { is: 4, message: "must have exactly 4 options" }
  
  validate :answers_must_be_unique
  validate :deadline_must_be_in_future, if: :deadline?

  private

  def answers_must_be_unique
    return if answers.empty?
    answer_texts = answers.map { |a| a.text.to_s.downcase.strip }.reject(&:blank?)
    duplicates = answer_texts.select { |text| answer_texts.count(text) > 1 }.uniq
    errors.add(:base, "Answer options must be unique") if duplicates.any?
  end

  def deadline_must_be_in_future
    errors.add(:deadline, "must be in the future") if deadline.present? && deadline <= Time.current
  end
end
```

#### Step 7: Create Answer Model (Repeat TDD)

```bash
# Generate Answer model
rails generate model Answer poll:references text:string position:integer

# Edit migration to add unique index and NOT NULL constraints
# Implement Answer model with validations
# Run tests → Green
```

#### Step 8: Run Model Tests (Green)

```bash
bundle exec rspec spec/models/
# All model tests should pass
```

### Phase 2: Controller Layer (PollsController)

#### Step 1: Create Request Spec Directory

```bash
mkdir -p spec/requests/polls
touch spec/requests/polls/get_new_spec.rb
touch spec/requests/polls/post_create_spec.rb
```

#### Step 2: Write Request Specs (Red)

**File**: `spec/requests/polls/get_new_spec.rb`

```ruby
require "rails_helper"

RSpec.describe "GET /polls/new", type: :request do
  context "when not authenticated" do
    it "redirects to login page" do
      get new_poll_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when authenticated" do
    let(:user) { create(:user) }

    before { sign_in user, scope: :user }

    it "renders the poll creation form" do
      get new_poll_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Create Poll")
    end
  end
end
```

#### Step 3: Generate Controller

```bash
rails generate controller Polls new create show

# This creates:
# - app/controllers/polls_controller.rb
# - app/views/polls/new.html.erb
# - app/views/polls/create.html.erb
# - app/views/polls/show.html.erb
# - app/helpers/polls_helper.rb
# - spec/requests/polls_spec.rb (delete this, use organized specs)
```

#### Step 4: Implement Controller

**File**: `app/controllers/polls_controller.rb`

```ruby
class PollsController < ApplicationController
  before_action :authenticate_user!

  def new
    @poll = Poll.new
    4.times { @poll.answers.build }
  end

  def create
    @poll = current_user.polls.build(poll_params)
    
    if @poll.save
      redirect_to @poll, notice: t(".success")
    else
      flash.now[:alert] = t(".error")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @poll = Poll.find(params[:id])
  end

  private

  def poll_params
    params.require(:poll).permit(:question, :deadline, answers_attributes: [ :text, :position ])
  end
end
```

#### Step 5: Add Routes

**File**: `config/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users, path: "", controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  resources :polls, only: [ :new, :create, :show ]
  
  root "home#index"
end
```

#### Step 6: Run Request Tests (Green)

```bash
bundle exec rspec spec/requests/polls/
# All request tests should pass
```

### Phase 3: View Layer

#### Step 1: Create Poll Form View

**File**: `app/views/polls/new.html.erb`

```erb
<div class="max-w-2xl mx-auto p-6">
  <h1 class="text-3xl font-bold mb-6"><%= t(".title") %></h1>

  <%= form_with model: @poll, local: true, class: "space-y-4" do |f| %>
    <% if @poll.errors.any? %>
      <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
        <ul>
          <% @poll.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div>
      <%= f.label :question, t(".question_label"), class: "block font-medium mb-2" %>
      <%= f.text_area :question, rows: 3, class: "w-full border rounded px-3 py-2", placeholder: t(".question_placeholder") %>
    </div>

    <div>
      <%= f.label :deadline, t(".deadline_label"), class: "block font-medium mb-2" %>
      <%= f.datetime_local_field :deadline, class: "border rounded px-3 py-2", min: Time.current.strftime("%Y-%m-%dT%H:%M") %>
      <p class="text-sm text-gray-600 mt-1"><%= t(".deadline_help") %></p>
    </div>

    <div>
      <h2 class="font-medium mb-2"><%= t(".answers_label") %></h2>
      <%= f.fields_for :answers do |answer_fields| %>
        <div class="mb-2">
          <%= answer_fields.label :text, "#{t('.answer_label')} #{answer_fields.index + 1}", class: "block text-sm mb-1" %>
          <%= answer_fields.text_field :text, class: "w-full border rounded px-3 py-2" %>
          <%= answer_fields.hidden_field :position, value: answer_fields.index + 1 %>
        </div>
      <% end %>
    </div>

    <div>
      <%= f.submit t(".submit"), class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded cursor-pointer" %>
    </div>
  <% end %>
</div>
```

#### Step 2: Create I18n Files

**File**: `config/locales/app/views/polls/new.en.yml`

```yaml
en:
  polls:
    new:
      title: "Create New Poll"
      question_label: "Poll Question"
      question_placeholder: "What would you like to ask?"
      deadline_label: "Deadline (Optional)"
      deadline_help: "Leave blank for no deadline"
      answers_label: "Answer Options"
      answer_label: "Answer"
      submit: "Create Poll"
```

**File**: `config/locales/app/controllers/polls/create.en.yml`

```yaml
en:
  polls:
    create:
      success: "Poll created successfully!"
      error: "Failed to create poll. Please check the form for errors."
```

#### Step 3: Create Show View

**File**: `app/views/polls/show.html.erb`

```erb
<div class="max-w-2xl mx-auto p-6">
  <h1 class="text-3xl font-bold mb-4"><%= @poll.question %></h1>
  
  <% if @poll.deadline.present? %>
    <p class="text-gray-600 mb-4">
      Deadline: <%= @poll.deadline.strftime("%B %d, %Y at %I:%M %p") %>
    </p>
  <% end %>

  <ul class="space-y-2">
    <% @poll.answers.ordered.each_with_index do |answer, index| %>
      <li class="border rounded p-3">
        <%= index + 1 %>. <%= answer.text %>
      </li>
    <% end %>
  </ul>

  <div class="mt-6">
    <%= link_to "Create Another Poll", new_poll_path, class: "text-blue-500 hover:underline" %>
  </div>
</div>
```

### Phase 4: System Tests (End-to-End)

#### Step 1: Create System Spec

**File**: `spec/system/poll_creation_spec.rb`

```ruby
require "rails_helper"

RSpec.describe "Poll Creation", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user, scope: :user
  end

  it "allows authenticated user to create a poll" do
    visit new_poll_path

    fill_in "Poll Question", with: "What is your favorite color?"
    fill_in "Answer 1", with: "Red"
    fill_in "Answer 2", with: "Blue"
    fill_in "Answer 3", with: "Green"
    fill_in "Answer 4", with: "Yellow"

    click_button "Create Poll"

    expect(page).to have_content("Poll created successfully!")
    expect(page).to have_content("What is your favorite color?")
    expect(page).to have_content("Red")
  end
end
```

#### Step 2: Run System Tests

```bash
bundle exec rspec spec/system/poll_creation_spec.rb
# Should pass
```

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/poll_spec.rb

# Run with documentation format
bundle exec rspec --format documentation

# Run with coverage
COVERAGE=true bundle exec rspec
```

## Code Quality Checks

```bash
# Run RuboCop
bin/rubocop

# Auto-fix RuboCop offenses
bin/rubocop -a

# Run RuboCop on specific files
bin/rubocop app/models/poll.rb app/controllers/polls_controller.rb
```

## Development Server

```bash
# Start Rails server
bin/dev

# Or just Rails (without Tailwind watch)
rails server

# Visit in browser
open http://localhost:3000

# Create a user (if needed)
# Navigate to: http://localhost:3000/sign_up

# Create a poll
# Navigate to: http://localhost:3000/polls/new
```

## Database Console

```bash
# Open Rails console
rails console

# Create a poll programmatically
user = User.first
poll = Poll.create!(
  user: user,
  question: "Best framework?",
  answers_attributes: [
    { text: "Rails", position: 1 },
    { text: "Django", position: 2 },
    { text: "Laravel", position: 3 },
    { text: "Express", position: 4 }
  ]
)

# Query polls
Poll.all
Poll.recent
user.polls
```

## Troubleshooting

### Issue: Tests failing with "Could not find a valid mapping for User"

**Solution**: Ensure `sign_in user, scope: :user` includes `scope: :user` parameter in all request/system specs.

### Issue: RuboCop violations after code generation

**Solution**: Run `bin/rubocop -a` to auto-fix formatting issues, then manually fix remaining offenses.

### Issue: Migration fails with "relation already exists"

**Solution**: 
```bash
# Roll back last migration
rails db:rollback

# Re-run migrations
rails db:migrate
```

### Issue: Nested attributes not saving

**Solution**: Verify `poll_params` includes `answers_attributes: [:text, :position]` in permitted parameters.

## Git Workflow

```bash
# Check current status
git status

# Stage changes
git add .

# Run tests before committing
bundle exec rspec

# Run RuboCop before committing
bin/rubocop

# Commit with descriptive message
git commit -m "feat: implement poll creation with nested answers"

# Push to feature branch
git push origin 002-create-poll
```

## Next Steps

1. Implement voting functionality (separate feature)
2. Add poll results display (separate feature)
3. Add poll listing page (separate feature)
4. Add poll editing/deletion (separate feature)

## Resources

- [Rails Guides - Nested Attributes](https://guides.rubyonrails.org/form_helpers.html#nested-forms)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [RSpec Rails Documentation](https://github.com/rspec/rspec-rails)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)
- [FactoryBot](https://github.com/thoughtbot/factory_bot)
