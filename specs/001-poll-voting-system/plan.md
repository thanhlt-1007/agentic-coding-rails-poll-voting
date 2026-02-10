# Implementation Plan: Poll Voting System

**Branch**: `001-poll-voting-system` | **Date**: February 10, 2026 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/001-poll-voting-system/spec.md`

## Summary

Build a poll voting system where creators can create polls with questions, multiple choices, and deadlines. Participants vote via shareable links (one vote per poll), with real-time results displayed based on configuration. Polls automatically close at deadline. Technical approach uses Rails 8 with Hotwire/Turbo for SSR and real-time updates, PostgreSQL for data persistence, Solid Queue for deadline management, and browser fingerprinting for duplicate vote prevention.

## Technical Context

**Language/Version**: Ruby 4.0.1, Rails 8.1.2  
**Primary Dependencies**: Turbo Rails (Hotwire), Stimulus JS, Tailwind CSS 4+, Solid Queue, Solid Cache, Solid Cable  
**Storage**: PostgreSQL 15+ (polls, choices, votes tables)  
**Testing**: Minitest (Rails default), Capybara (system tests), FactoryBot (test data)  
**Target Platform**: Web application (desktop + mobile responsive), deployed to Render.com  
**Project Type**: Rails monolith with SSR-first architecture  
**Performance Goals**: Poll creation < 60s, voting < 15s, real-time updates < 2s latency, 100+ concurrent voters per poll  
**Constraints**: <500ms p95 response time, <200ms vote submission, real-time via Turbo Streams only (no external WebSocket libs), 90%+ test coverage  
**Scale/Scope**: MVP supports unlimited polls, 10k votes/poll, 50 choices/poll, anonymous participants (no authentication)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

✅ **Rails-First Architecture**: Using Rails 8 conventions (generators, MVC, Active Record, Turbo, ViewComponents)  
✅ **TDD NON-NEGOTIABLE**: Minitest with 90%+ coverage, write tests before implementation  
✅ **SSR Performance**: Turbo Streams for real-time updates, fragment caching, eager loading for N+1 prevention  
✅ **Security by Default**: Strong parameters, CSRF protection, XSS prevention, SQL injection protection via AR  
✅ **Simplicity & Maintainability**: No external JavaScript libraries beyond importmap defaults, Rails patterns only  
✅ **PostgreSQL 15+**: Per constitution  
✅ **Solid Queue/Cache/Cable**: Per constitution (no Redis needed)  
✅ **Tailwind CSS**: Per constitution  
✅ **Deployment**: Render.com per constitution and RENDER.md guide  

**Constitutional Compliance**: ✅ PASSED - No violations, all requirements aligned with constitution

## Project Structure

### Documentation (this feature)

```text
specs/001-poll-voting-system/
├── spec.en.md           # English specification (source of truth)
├── spec.vi.md           # Vietnamese specification (translation)
├── plan.en.md           # This file (English technical plan)
├── plan.vi.md           # Vietnamese technical plan (to be created)
├── checklists/
│   └── requirements.md  # Specification validation checklist
└── research.md          # Phase 0 output (if needed)
```

### Source Code (Rails monolith structure)

```text
app/
├── models/
│   ├── poll.rb              # Poll model (question, deadline, status, access_code)
│   ├── choice.rb            # Choice model (belongs_to :poll, has_many :votes)
│   ├── vote.rb              # Vote model (belongs_to :choice, :poll, unique participant)
│   └── concerns/
│       └── votable.rb       # Shared voting logic (if needed)
├── controllers/
│   ├── polls_controller.rb  # CRUD for polls (new, create, show, edit, update, close)
│   └── votes_controller.rb  # Voting endpoint (create, validates duplicate prevention)
├── views/
│   ├── polls/
│   │   ├── new.html.erb     # Poll creation form
│   │   ├── show.html.erb    # Poll display + voting interface
│   │   ├── edit.html.erb    # Poll editing (pre-votes only)
│   │   ├── _form.html.erb   # Poll form partial
│   │   └── _results.html.erb # Results partial (for Turbo Stream updates)
│   └── votes/
│       └── _confirmation.html.erb # Vote confirmation message
├── javascript/
│   └── controllers/
│       ├── countdown_controller.js  # Stimulus: deadline countdown timer
│       └── vote_controller.js       # Stimulus: vote button handling
├── jobs/
│   └── close_expired_polls_job.rb   # Solid Queue: close polls past deadline
└── helpers/
    └── polls_helper.rb              # Time formatting, percentage calculations

config/
├── routes.rb                # Poll routes: resources :polls, nested votes
└── initializers/
    └── solid_queue.rb       # Solid Queue configuration for recurring jobs

db/
├── migrate/
│   ├── [timestamp]_create_polls.rb
│   ├── [timestamp]_create_choices.rb
│   └── [timestamp]_create_votes.rb
└── schema.rb                # Auto-generated schema

test/
├── models/
│   ├── poll_test.rb         # Poll validations, associations, business logic
│   ├── choice_test.rb       # Choice validations, vote counting
│   └── vote_test.rb         # Duplicate prevention, timestamp validation
├── controllers/
│   ├── polls_controller_test.rb  # Request tests for poll CRUD
│   └── votes_controller_test.rb  # Request tests for voting
├── system/
│   ├── create_poll_test.rb       # E2E: Create poll, receive link
│   ├── vote_on_poll_test.rb      # E2E: Vote, see confirmation
│   ├── real_time_results_test.rb # E2E: Real-time updates via Turbo
│   └── poll_closure_test.rb      # E2E: Deadline enforcement
└── factories/
    ├── polls.rb
    ├── choices.rb
    └── votes.rb
```

**Structure Decision**: Rails monolith with standard MVC architecture. All code in `app/` following Rails conventions. Turbo Streams handle real-time updates server-side (no separate frontend build). Solid Queue background jobs for deadline management. Tests organized by type (models, controllers, system).

## Complexity Tracking

**No constitutional violations** - this is a straightforward Rails application following all constitutional principles. No complexity justification required.

## Database Schema

### Polls Table

```ruby
# db/migrate/[timestamp]_create_polls.rb
create_table :polls do |t|
  t.string :question, null: false, limit: 500
  t.datetime :deadline, null: false
  t.string :access_code, null: false, limit: 8, index: { unique: true }
  t.boolean :show_results_while_voting, default: false, null: false
  t.string :status, default: 'active', null: false # active, closed
  t.integer :total_votes, default: 0, null: false # Cache for performance
  
  t.timestamps
  
  # Indexes
  t.index :status
  t.index :deadline
end

# Validations (in poll.rb)
validates :question, presence: true, length: { maximum: 500 }
validates :deadline, presence: true
validate :deadline_must_be_in_future, on: :create
validates :access_code, presence: true, uniqueness: true
validates :status, inclusion: { in: %w[active closed] }
has_many :choices, dependent: :destroy
has_many :votes, through: :choices
accepts_nested_attributes_for :choices, reject_if: :all_blank

# Custom methods
def active?
  status == 'active' && deadline > Time.current
end

def closed?
  status == 'closed' || deadline <= Time.current
end

def close!
  update!(status: 'closed')
end

before_create :generate_access_code

private

def generate_access_code
  self.access_code = SecureRandom.urlsafe_base64(6).upcase[0..7]
end

def deadline_must_be_in_future
  errors.add(:deadline, "must be in the future") if deadline.present? && deadline <= Time.current
end
```

### Choices Table

```ruby
# db/migrate/[timestamp]_create_choices.rb
create_table :choices do |t|
  t.references :poll, null: false, foreign_key: true, index: true
  t.string :text, null: false, limit: 200
  t.integer :position, default: 0, null: false
  t.integer :votes_count, default: 0, null: false # Counter cache
  
  t.timestamps
  
  # Indexes
  t.index [:poll_id, :position]
end

# Validations (in choice.rb)
belongs_to :poll
has_many :votes, dependent: :destroy
validates :text, presence: true, length: { maximum: 200 }
validates :poll_id, presence: true

# Counter cache updates
after_create :update_poll_total_votes
after_destroy :update_poll_total_votes

def percentage
  return 0 if poll.total_votes.zero?
  (votes_count.to_f / poll.total_votes * 100).round(1)
end
```

### Votes Table

```ruby
# db/migrate/[timestamp]_create_votes.rb
create_table :votes do |t|
  t.references :poll, null: false, foreign_key: true, index: true
  t.references :choice, null: false, foreign_key: true, index: true
  t.string :participant_fingerprint, null: false, limit: 64 # SHA256 hash
  t.string :ip_hash, null: false, limit: 64 # SHA256 of IP
  t.string :session_token, limit: 64 # Session identifier
  t.datetime :voted_at, null: false
  
  t.timestamps
  
  # Composite unique index to prevent duplicate votes
  t.index [:poll_id, :participant_fingerprint], unique: true, name: 'index_votes_on_poll_and_participant'
  t.index :voted_at
  t.index :ip_hash
end

# Validations (in vote.rb)
belongs_to :poll, counter_cache: :total_votes
belongs_to :choice, counter_cache: :votes_count
validates :poll_id, presence: true
validates :choice_id, presence: true
validates :participant_fingerprint, presence: true, uniqueness: { scope: :poll_id }
validates :voted_at, presence: true
validate :poll_must_be_active
validate :deadline_not_passed

before_validation :set_voted_at, :generate_fingerprint

private

def set_voted_at
  self.voted_at ||= Time.current
end

def generate_fingerprint
  # Combines IP + User-Agent + Session for unique identification
  data = "#{ip_hash}-#{request.user_agent}-#{session_token}"
  self.participant_fingerprint = Digest::SHA256.hexdigest(data)
end

def poll_must_be_active
  errors.add(:poll, "must be active") unless poll&.active?
end

def deadline_not_passed
  errors.add(:base, "Poll has closed") if poll && poll.deadline <= Time.current
end
```

## Routes Configuration

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "welcome#index" # Existing welcome page
  
  resources :polls, param: :access_code, only: [:new, :create, :show, :edit, :update] do
    member do
      patch :close  # Manual close action
    end
    
    resources :votes, only: [:create], shallow: true
  end
  
  # Health check for Render.com
  get "up" => "rails/health#show", as: :rails_health_check
end

# Generated routes:
# GET    /polls/new                → polls#new      (poll creation form)
# POST   /polls                    → polls#create   (create poll)
# GET    /polls/:access_code       → polls#show     (view poll + vote interface)
# GET    /polls/:access_code/edit  → polls#edit     (edit poll - pre-votes only)
# PATCH  /polls/:access_code       → polls#update   (update poll)
# PATCH  /polls/:access_code/close → polls#close    (manual close)
# POST   /polls/:poll_access_code/votes → votes#create (submit vote)
```

## Controllers Implementation

### PollsController

```ruby
class PollsController < ApplicationController
  before_action :set_poll, only: [:show, :edit, :update, :close]
  
  def new
    @poll = Poll.new
    3.times { @poll.choices.build } # Start with 3 empty choices
  end
  
  def create
    @poll = Poll.new(poll_params)
    
    if @poll.save
      redirect_to poll_path(@poll.access_code), notice: "Poll created! Share this link with participants."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    @vote = Vote.new(poll: @poll)
    @participant_voted = @poll.votes.exists?(participant_fingerprint: current_participant_fingerprint)
    
    if @participant_voted
      @participant_vote = @poll.votes.find_by(participant_fingerprint: current_participant_fingerprint)
    end
  end
  
  def edit
    if @poll.votes.any?
      redirect_to poll_path(@poll.access_code), alert: "Cannot edit poll after votes are recorded."
    end
  end
  
  def update
    if @poll.votes.any?
      redirect_to poll_path(@poll.access_code), alert: "Cannot modify poll after votes are recorded."
      return
    end
    
    if @poll.update(poll_params)
      redirect_to poll_path(@poll.access_code), notice: "Poll updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def close
    @poll.close!
    redirect_to poll_path(@poll.access_code), notice: "Poll closed successfully."
  end
  
  private
  
  def set_poll
    @poll = Poll.find_by!(access_code: params[:access_code])
  end
  
  def poll_params
    params.require(:poll).permit(
      :question, :deadline, :show_results_while_voting,
      choices_attributes: [:id, :text, :position, :_destroy]
    )
  end
  
  def current_participant_fingerprint
    data = "#{request.remote_ip}-#{request.user_agent}-#{session.id}"
    Digest::SHA256.hexdigest(data)
  end
end
```

### VotesController

```ruby
class VotesController < ApplicationController
  before_action :set_poll
  before_action :check_duplicate_vote
  
  def create
    @vote = @poll.votes.new(vote_params)
    @vote.ip_hash = Digest::SHA256.hexdigest(request.remote_ip)
    @vote.session_token = session.id
    @vote.participant_fingerprint = current_participant_fingerprint
    
    if @vote.save
      # Broadcast real-time update via Turbo Stream
      broadcast_vote_update
      
      respond_to do |format|
        format.html { redirect_to poll_path(@poll.access_code), notice: "Thank you for voting!" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to poll_path(@poll.access_code), alert: @vote.errors.full_messages.join(", ") }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("vote-form", partial: "votes/error", locals: { errors: @vote.errors }) }
      end
    end
  end
  
  private
  
  def set_poll
    @poll = Poll.find_by!(access_code: params[:poll_access_code])
  end
  
  def check_duplicate_vote
    if @poll.votes.exists?(participant_fingerprint: current_participant_fingerprint)
      redirect_to poll_path(@poll.access_code), alert: "You have already voted on this poll."
    end
  end
  
  def vote_params
    params.require(:vote).permit(:choice_id)
  end
  
  def current_participant_fingerprint
    data = "#{request.remote_ip}-#{request.user_agent}-#{session.id}"
    Digest::SHA256.hexdigest(data)
  end
  
  def broadcast_vote_update
    # Broadcast to all viewers of this poll
    broadcast_replace_to [@poll, :results],
      target: "poll-results",
      partial: "polls/results",
      locals: { poll: @poll.reload }
  end
end
```

## Real-Time Updates (Turbo Streams)

### View Setup

```erb
<!-- app/views/polls/show.html.erb -->
<div class="poll-container">
  <%= turbo_stream_from [@poll, :results] %>
  
  <h1><%= @poll.question %></h1>
  
  <% if @poll.closed? %>
    <p class="alert alert-info">This poll has closed. Results:</p>
  <% elsif @participant_voted %>
    <p class="alert alert-success">You have already voted on this poll.</p>
  <% else %>
    <p class="countdown" data-controller="countdown" data-countdown-deadline-value="<%= @poll.deadline.iso8601 %>">
      Time remaining: <span data-countdown-target="display"></span>
    </p>
  <% end %>
  
  <%= turbo_frame_tag "vote-form" do %>
    <% unless @participant_voted || @poll.closed? %>
      <%= render "votes/form", poll: @poll, vote: @vote %>
    <% end %>
  <% end %>
  
  <div id="poll-results">
    <%= render "polls/results", poll: @poll %>
  </div>
</div>
```

```erb
<!-- app/views/polls/_results.html.erb -->
<% if poll.show_results_while_voting || poll.closed? %>
  <div class="results">
    <h2>Results</h2>
    <% poll.choices.each do |choice| %>
      <div class="choice-result">
        <span class="choice-text"><%= choice.text %></span>
        <div class="vote-bar" style="width: <%= choice.percentage %>%"></div>
        <span class="vote-count"><%= choice.votes_count %> votes (<%= choice.percentage %>%)</span>
      </div>
    <% end %>
    <p class="total-votes">Total votes: <%= poll.total_votes %></p>
  </div>
<% else %>
  <p class="text-muted">Results will be visible after the poll closes.</p>
<% end %>
```

### Stimulus Controller for Countdown

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { deadline: String }
  
  connect() {
    this.updateCountdown()
    this.interval = setInterval(() => this.updateCountdown(), 1000)
  }
  
  disconnect() {
    clearInterval(this.interval)
  }
  
  updateCountdown() {
    const now = new Date()
    const deadline = new Date(this.deadlineValue)
    const diff = deadline - now
    
    if (diff <= 0) {
      this.displayTarget.textContent = "Poll closed"
      clearInterval(this.interval)
      window.location.reload() // Reload to show closed state
      return
    }
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((diff % (1000 * 60)) / 1000)
    
    let display = ""
    if (days > 0) display += `${days}d `
    if (hours > 0 || days > 0) display += `${hours}h `
    display += `${minutes}m ${seconds}s`
    
    this.displayTarget.textContent = display
  }
}
```

## Background Jobs (Solid Queue)

### Close Expired Polls Job

```ruby
# app/jobs/close_expired_polls_job.rb
class CloseExpiredPollsJob < ApplicationJob
  queue_as :default
  
  def perform
    expired_polls = Poll.where(status: 'active').where('deadline <= ?', Time.current)
    
    expired_polls.find_each do |poll|
      poll.close!
      
      # Broadcast closure to all viewers
      broadcast_replace_to [poll, :results],
        target: "poll-results",
        partial: "polls/results",
        locals: { poll: poll }
      
      Rails.logger.info "Closed poll #{poll.access_code} (ID: #{poll.id})"
    end
    
    Rails.logger.info "Processed #{expired_polls.count} expired polls"
  end
end
```

### Solid Queue Configuration

```ruby
# config/initializers/solid_queue.rb
Rails.application.config.after_initialize do
  if defined?(SolidQueue)
    # Schedule recurring job to check for expired polls every minute
    SolidQueue::RecurringTask.create_or_find_by!(
      key: "close_expired_polls",
      class_name: "CloseExpiredPollsJob",
      schedule: "every minute"
    )
  end
end
```

## Testing Strategy

### Model Tests

```ruby
# test/models/poll_test.rb
require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "should not save poll without question" do
    poll = Poll.new(deadline: 1.day.from_now)
    assert_not poll.save, "Saved poll without question"
  end
  
  test "should not save poll with past deadline" do
    poll = Poll.new(question: "Test?", deadline: 1.day.ago)
    assert_not poll.save, "Saved poll with past deadline"
  end
  
  test "should generate unique access code on create" do
    poll = Poll.create!(question: "Test?", deadline: 1.day.from_now)
    assert_not_nil poll.access_code
    assert_equal 8, poll.access_code.length
  end
  
  test "should require minimum 2 choices" do
    poll = Poll.new(question: "Test?", deadline: 1.day.from_now)
    poll.choices.build(text: "Only one")
    assert_not poll.save, "Saved poll with only 1 choice"
  end
  
  test "active? should return true for active poll before deadline" do
    poll = create(:poll, status: 'active', deadline: 1.day.from_now)
    assert poll.active?
  end
  
  test "closed? should return true after deadline" do
    poll = create(:poll, deadline: 1.hour.ago)
    assert poll.closed?
  end
end

# test/models/vote_test.rb
require "test_helper"

class VoteTest < ActiveSupport::TestCase
  test "should prevent duplicate votes from same participant" do
    poll = create(:poll)
    choice = create(:choice, poll: poll)
    fingerprint = "abc123"
    
    vote1 = Vote.create!(poll: poll, choice: choice, participant_fingerprint: fingerprint)
    vote2 = Vote.new(poll: poll, choice: choice, participant_fingerprint: fingerprint)
    
    assert_not vote2.save, "Saved duplicate vote"
  end
  
  test "should not allow voting on closed poll" do
    poll = create(:poll, status: 'closed')
    choice = create(:choice, poll: poll)
    vote = Vote.new(poll: poll, choice: choice, participant_fingerprint: "abc123")
    
    assert_not vote.save, "Voted on closed poll"
  end
  
  test "should increment counter caches" do
    poll = create(:poll)
    choice = create(:choice, poll: poll)
    
    assert_difference 'choice.reload.votes_count', 1 do
      assert_difference 'poll.reload.total_votes', 1 do
        create(:vote, poll: poll, choice: choice)
      end
    end
  end
end
```

### System Tests

```ruby
# test/system/create_poll_test.rb
require "application_system_test_case"

class CreatePollTest < ApplicationSystemTestCase
  test "creating a poll with valid data" do
    visit new_poll_path
    
    fill_in "Question", with: "What's your favorite color?"
    fill_in "poll_choices_attributes_0_text", with: "Red"
    fill_in "poll_choices_attributes_1_text", with: "Blue"
    fill_in "poll_choices_attributes_2_text", with: "Green"
    fill_in "Deadline", with: 1.day.from_now
    
    click_button "Create Poll"
    
    assert_text "Poll created!"
    assert_current_path /\/polls\/[A-Z0-9]{8}/
  end
  
  test "shows validation errors for invalid poll" do
    visit new_poll_path
    
    # Only add 1 choice (minimum is 2)
    fill_in "poll_choices_attributes_0_text", with: "Only one"
    fill_in "Deadline", with: 1.day.from_now
    
    click_button "Create Poll"
    
    assert_text "must have at least 2 choices"
  end
end

# test/system/vote_on_poll_test.rb
require "application_system_test_case"

class VoteOnPollTest < ApplicationSystemTestCase
  test "voting on an active poll" do
    poll = create(:poll, :with_choices)
    
    visit poll_path(poll.access_code)
    
    assert_text poll.question
    choose poll.choices.first.text
    click_button "Submit Vote"
    
    assert_text "Thank you for voting!"
    assert_text "You have already voted on this poll"
  end
  
  test "cannot vote twice on same poll" do
    poll = create(:poll, :with_choices)
    create(:vote, poll: poll, choice: poll.choices.first, participant_fingerprint: "test123")
    
    # Simulate same participant
    using_session("test123") do
      visit poll_path(poll.access_code)
      
      assert_text "You have already voted on this poll"
      assert_no_button "Submit Vote"
    end
  end
  
  test "shows closed message after deadline" do
    poll = create(:poll, :closed)
    
    visit poll_path(poll.access_code)
    
    assert_text "This poll has closed"
    assert_no_button "Submit Vote"
  end
end
```

## Security Implementation

### Duplicate Vote Prevention

```ruby
# app/controllers/concerns/participant_identification.rb
module ParticipantIdentification
  extend ActiveSupport::Concern
  
  private
  
  def current_participant_fingerprint
    # Multi-layer fingerprinting
    components = [
      request.remote_ip,
      request.user_agent || 'unknown',
      session.id.to_s
    ]
    
    Digest::SHA256.hexdigest(components.join('-'))
  end
  
  def participant_ip_hash
    Digest::SHA256.hexdigest(request.remote_ip)
  end
end
```

### Rate Limiting (Rack::Attack)

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle voting attempts
  throttle('votes/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path.include?('/votes') && req.post?
  end
  
  # Throttle poll creation
  throttle('polls/ip', limit: 5, period: 1.hour) do |req|
    req.ip if req.path == '/polls' && req.post?
  end
end
```

## Performance Optimizations

### Database Indexes

```ruby
# Already included in schema above:
# - access_code (unique index)
# - poll_id, participant_fingerprint (composite unique)
# - counter_cache columns (votes_count, total_votes)
# - status, deadline (for job queries)
```

### Query Optimization

```ruby
# In PollsController#show
def show
  @poll = Poll.includes(choices: :votes).find_by!(access_code: params[:access_code])
  # Eager loads choices and votes to prevent N+1
end
```

### Caching Strategy

```ruby
# In polls/_results.html.erb
<% cache [@poll, @poll.updated_at, "results"] do %>
  <!-- Results HTML -->
<% end %>

# Fragment cache invalidation happens automatically via updated_at touch
```

## Deployment Configuration

### Database Migrations Order

1. `rails generate migration CreatePolls`
2. `rails generate migration CreateChoices`
3. `rails generate migration CreateVotes`
4. `rails db:migrate`

### Environment Variables (Render.com)

Per RENDER.md and constitution:
- `DATABASE_URL` (auto-provided by Render.com)
- `REDIS_URL` (auto-provided, though Solid Queue doesn't need it)
- `RAILS_MASTER_KEY` (manual configuration)
- `RAILS_ENV=production`
- `RAILS_LOG_LEVEL=info`
- `RAILS_FORCE_SSL=true`

### Build Command

```bash
bundle install && bundle exec rails assets:precompile && bundle exec rails db:prepare
```

### Start Command

```bash
bundle exec rails server -b 0.0.0.0
```

## Implementation Phases

### Phase 1: Core Models & Database (P1 - Foundation)

**Duration**: 1-2 days  
**Deliverables**:
- [ ] Create migrations for polls, choices, votes tables
- [ ] Implement Poll model with validations, associations
- [ ] Implement Choice model with counter cache
- [ ] Implement Vote model with duplicate prevention
- [ ] Write model tests (90%+ coverage)
- [ ] Run migrations, verify schema

**Testing**:
- Model unit tests for validations
- Association tests
- Counter cache tests
- Unique constraint tests

### Phase 2: Poll Creation & Display (P1 - MVP Slice 1)

**Duration**: 2-3 days  
**Deliverables**:
- [ ] Generate PollsController with new, create, show actions
- [ ] Create poll form view with nested choices
- [ ] Implement access code generation
- [ ] Add routes configuration
- [ ] Implement poll display page
- [ ] Write controller and system tests

**Testing**:
- Request tests for poll CRUD
- System test: create poll, receive link
- System test: view poll via access code
- Validation error handling tests

### Phase 3: Voting Functionality (P1 - MVP Slice 2)

**Duration**: 2-3 days  
**Deliverables**:
- [ ] Generate VotesController with create action
- [ ] Implement participant fingerprinting
- [ ] Add duplicate vote check
- [ ] Create voting form and confirmation views
- [ ] Implement vote validation
- [ ] Write controller and system tests

**Testing**:
- Request tests for voting
- System test: submit vote, see confirmation
- System test: duplicate vote prevention
- System test: vote on closed poll (should fail)

### Phase 4: Real-Time Updates (P2 - Enhancement)

**Duration**: 2-3 days  
**Deliverables**:
- [ ] Implement Turbo Stream broadcasts
- [ ] Add results partial with vote percentages
- [ ] Create Stimulus countdown controller
- [ ] Implement show/hide results logic
- [ ] Add real-time result updates
- [ ] Write system tests for real-time features

**Testing**:
- System test: real-time updates (2 browser windows)
- System test: results visibility configuration
- JavaScript controller tests

### Phase 5: Poll Management (P3 - Optional)

**Duration**: 1-2 days  
**Deliverables**:
- [ ] Implement edit/update actions (pre-vote only)
- [ ] Add manual close action
- [ ] Create statistics view
- [ ] Add CSV export functionality
- [ ] Write tests for management features

**Testing**:
- Request tests for edit/update
- System test: edit before votes
- System test: edit blocked after votes
- System test: manual poll closure

### Phase 6: Background Jobs & Deadline Management (P2 - Critical)

**Duration**: 1-2 days  
**Deliverables**:
- [ ] Create CloseExpiredPollsJob
- [ ] Configure Solid Queue recurring task
- [ ] Implement deadline enforcement
- [ ] Add job monitoring
- [ ] Write job tests

**Testing**:
- Job unit tests
- Integration test: poll closes at deadline
- System test: voting blocked after deadline

### Phase 7: Polish & Production Readiness (Required)

**Duration**: 2-3 days  
**Deliverables**:
- [ ] Add Tailwind CSS styling
- [ ] Implement responsive design
- [ ] Add accessibility features (ARIA labels, keyboard nav)
- [ ] Performance optimization (caching, eager loading)
- [ ] Security hardening (Rack::Attack rate limiting)
- [ ] Production testing on Render.com
- [ ] Documentation updates

**Testing**:
- Accessibility testing (screen reader, keyboard)
- Mobile responsive testing (iOS, Android)
- Load testing (100 concurrent users)
- Production smoke tests

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Duplicate vote circumvention | High | Multi-layer fingerprinting (IP + UA + session), rate limiting |
| Race conditions on vote counting | Medium | Database atomic transactions, counter cache locks |
| Real-time broadcast performance | Medium | Fragment caching, limit broadcast frequency to 2s |
| Deadline job failure | High | Solid Queue reliability, job monitoring, retry logic |
| Poll access code collisions | Low | 8-char base64 = 2^48 combinations, uniqueness constraint |
| Session hijacking for voting | Medium | HTTPS only, secure session cookies, CSRF protection |

## Success Metrics

- [ ] All 15 functional requirements (FR-001 to FR-015) implemented
- [ ] All 10 success criteria (SC-001 to SC-010) validated
- [ ] Test coverage ≥90% on models and controllers
- [ ] All 4 user stories (P1, P1, P2, P3) complete with acceptance tests
- [ ] Performance benchmarks met (< 60s poll creation, < 15s voting, < 2s real-time updates)
- [ ] Zero security vulnerabilities (Brakeman scan clean)
- [ ] Responsive design works on iOS and Android
- [ ] Deployed to Render.com successfully

## Next Steps

1. **Review Plan**: Team review this technical plan for feedback
2. **Phase 0 Research** (if needed): Create research.md for any NEEDS CLARIFICATION items
3. **Phase 1 Execution**: Begin with database schema and model implementation
4. **Generate Tasks**: Run `/speckit.tasks` to create granular implementation tasks
5. **Start Development**: Follow TDD workflow, implement P1 features first

---

**Plan Status**: ✅ READY FOR IMPLEMENTATION  
**Estimated Timeline**: 12-16 days (P1-P2 features), +3-4 days for P3 features  
**Team Capacity**: 1-2 developers
