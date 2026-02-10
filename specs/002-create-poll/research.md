# Phase 0: Research - Poll Creation

**Feature**: Poll Creation  
**Branch**: `002-create-poll`  
**Date**: February 11, 2026

## Research Tasks

This document consolidates research findings to resolve all "NEEDS CLARIFICATION" items from the Technical Context and inform design decisions for Phase 1.

## 1. Rails Nested Attributes for Poll + Answers

**Decision**: Use `accepts_nested_attributes_for` for creating polls with embedded answers in a single form submission

**Rationale**:
- Rails provides built-in support for nested attributes via `accepts_nested_attributes_for`
- Allows creating parent (Poll) and children (Answers) records in one transaction
- Simplifies form handling with `fields_for` helper
- Automatic validation and rollback on errors
- Standard Rails pattern for has_many relationships

**Implementation Pattern**:
```ruby
# app/models/poll.rb
class Poll < ApplicationRecord
  has_many :answers, dependent: :destroy
  accepts_nested_attributes_for :answers, 
    reject_if: :all_blank, 
    allow_destroy: false

  validates :question, presence: true
  validates :answers, length: { is: 4 }
end

# Controller params
def poll_params
  params.require(:poll).permit(
    :question, 
    :deadline,
    answers_attributes: [:text, :position]
  )
end

# View form
<%= form_with model: @poll do |f| %>
  <%= f.text_field :question %>
  <%= f.datetime_local_field :deadline %>
  
  <%= f.fields_for :answers do |answer_fields| %>
    <%= answer_fields.text_field :text %>
    <%= answer_fields.hidden_field :position %>
  <% end %>
<% end %>
```

**Alternatives Considered**:
- **Custom service object**: More complex, reinvents Rails functionality
- **Separate answer creation**: Requires multiple requests, worse UX
- **JSON field for answers**: Loses relational integrity, harder to query

**Best Practices**:
- Always wrap in transaction (automatic with nested attributes)
- Use `reject_if: :all_blank` to ignore empty answer fields
- Set `allow_destroy: false` for creation forms (only true for edit forms)
- Validate answer count at Poll level (`validates :answers, length: { is: 4 }`)
- Use `position` field to maintain answer order

## 2. Answer Uniqueness Validation

**Decision**: Implement custom validation method to check for duplicate answer text within a poll

**Rationale**:
- Rails doesn't provide built-in uniqueness validation for nested attributes scope
- Must validate uniqueness within poll context (not globally unique)
- Custom validation gives better error messages
- Can use case-insensitive comparison

**Implementation Pattern**:
```ruby
# app/models/poll.rb
class Poll < ApplicationRecord
  validate :answers_must_be_unique

  private

  def answers_must_be_unique
    answer_texts = answers.map { |a| a.text.to_s.downcase.strip }
    duplicates = answer_texts.select { |text| answer_texts.count(text) > 1 }.uniq
    
    if duplicates.any?
      errors.add(:base, "Answer options must be unique: #{duplicates.join(', ')}")
    end
  end
end
```

**Alternatives Considered**:
- **Database unique index**: Cannot scope to poll, would prevent same text across different polls
- **Validate uniqueness in Answer model**: Harder to provide good error messages for form
- **JavaScript validation**: Not reliable (can be bypassed), server-side validation still needed

**Best Practices**:
- Normalize text (downcase, strip whitespace) before comparison
- Add error to `:base` for poll-level validation
- Provide helpful error message listing duplicate values
- Run validation before save (in model validation lifecycle)

## 3. Deadline Validation (Future Date)

**Decision**: Use custom validation to ensure deadline is in the future, using server time as reference

**Rationale**:
- Must validate against server time to prevent timezone exploitation
- Deadline is optional, so validation only runs when present
- Need to allow "close to now" deadlines (within 1 minute grace period)

**Implementation Pattern**:
```ruby
# app/models/poll.rb
class Poll < ApplicationRecord
  validate :deadline_must_be_in_future, if: :deadline?

  private

  def deadline_must_be_in_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "must be in the future")
    end
  end
end
```

**Alternatives Considered**:
- **Client-side validation only**: Can be bypassed, unreliable
- **Comparison to `Time.now`**: Less accurate than `Time.current` (Rails timezone-aware)
- **Strict comparison (no grace period)**: May cause issues with form submission timing

**Best Practices**:
- Use `Time.current` instead of `Time.now` (timezone-aware)
- Use conditional validation `if: :deadline?` to skip when nil
- Provide user-friendly error message
- Consider adding maximum deadline range validation (e.g., not more than 1 year in future)

## 4. Form Input for Deadline

**Decision**: Use `datetime_local_field` HTML5 input for deadline selection

**Rationale**:
- Native HTML5 date/time picker (browser support excellent in 2026)
- No JavaScript library needed
- Automatic browser timezone handling
- Rails form helper support built-in
- Accessible and mobile-friendly

**Implementation Pattern**:
```erb
<%= form.datetime_local_field :deadline, 
  class: "form-control",
  placeholder: "Optional: Select deadline",
  min: Time.current.strftime("%Y-%m-%dT%H:%M") %>
```

**Alternatives Considered**:
- **Flatpickr JavaScript library**: Additional dependency, not needed with HTML5 support
- **Separate date and time fields**: Worse UX, more complex validation
- **Text input with manual parsing**: Error-prone, bad UX

**Best Practices**:
- Set `min` attribute to current time (client-side hint, still validate server-side)
- Make field optional (blank is allowed)
- Provide placeholder text indicating it's optional
- Display timezone information to user if needed

## 5. Nested Attributes Testing Strategy

**Decision**: Test nested attributes at multiple levels (model, request, system)

**Rationale**:
- Model specs test validation logic in isolation
- Request specs test controller param handling and response behavior
- System specs test end-to-end user experience with real form

**Testing Patterns**:
```ruby
# spec/models/poll_spec.rb
describe "nested answers" do
  it "creates poll with 4 answers via nested attributes" do
    poll_params = {
      question: "Test?",
      answers_attributes: [
        { text: "A", position: 1 },
        { text: "B", position: 2 },
        { text: "C", position: 3 },
        { text: "D", position: 4 }
      ]
    }
    poll = Poll.create!(poll_params)
    expect(poll.answers.count).to eq(4)
  end
  
  it "rejects poll with duplicate answers" do
    poll_params = {
      question: "Test?",
      answers_attributes: [
        { text: "Same", position: 1 },
        { text: "Same", position: 2 },
        { text: "C", position: 3 },
        { text: "D", position: 4 }
      ]
    }
    poll = Poll.new(poll_params)
    expect(poll).not_to be_valid
    expect(poll.errors[:base]).to include(match(/must be unique/))
  end
end

# spec/requests/polls/post_create_spec.rb
it "creates poll with nested answers" do
  post polls_path, params: {
    poll: {
      question: "Best color?",
      answers_attributes: {
        "0" => { text: "Red", position: 1 },
        "1" => { text: "Blue", position: 2 },
        "2" => { text: "Green", position: 3 },
        "3" => { text: "Yellow", position: 4 }
      }
    }
  }
  
  expect(response).to redirect_to(poll_path(Poll.last))
  expect(Poll.last.answers.count).to eq(4)
end
```

**Best Practices**:
- Test happy path (valid nested attributes)
- Test validation failures (duplicate answers, missing answers, wrong count)
- Test edge cases (blank answers with reject_if)
- Use FactoryBot traits for different poll states
- System specs verify actual form submission works

## 6. Authentication Integration (Devise)

**Decision**: Use Devise's `authenticate_user!` before_action filter for poll controller actions

**Rationale**:
- Existing Devise setup from specs/001-user-signup
- Standard Rails authentication pattern
- Automatic redirect to login with return URL
- Test helpers available (`sign_in user, scope: :user`)

**Implementation Pattern**:
```ruby
# app/controllers/polls_controller.rb
class PollsController < ApplicationController
  before_action :authenticate_user!

  def new
    @poll = Poll.new
    4.times { @poll.answers.build }
  end

  def create
    @poll = current_user.polls.build(poll_params)
    # ...
  end
end

# spec/requests/polls/get_new_spec.rb
context "when not authenticated" do
  it "redirects to login page" do
    get new_poll_path
    expect(response).to redirect_to(new_user_session_path)
  end
end

context "when authenticated" do
  let(:user) { create(:user) }
  
  before { sign_in user, scope: :user }
  
  it "renders new poll form" do
    get new_poll_path
    expect(response).to have_http_status(:ok)
  end
end
```

**Best Practices**:
- Use `before_action :authenticate_user!` at controller level
- Associate polls with creator: `current_user.polls.build(poll_params)`
- Always include `scope: :user` in test `sign_in` helper calls
- Test both authenticated and unauthenticated scenarios

## 7. Flash Message Patterns

**Decision**: Use Rails flash for success/error messages with i18n

**Rationale**:
- Standard Rails pattern for user feedback
- I18n support for flash messages
- Works with Turbo/Hotwire (no JavaScript needed)
- Existing flash display infrastructure in application layout

**Implementation Pattern**:
```ruby
# app/controllers/polls_controller.rb
def create
  @poll = current_user.polls.build(poll_params)
  
  if @poll.save
    redirect_to @poll, notice: t('.success')
  else
    flash.now[:alert] = t('.error')
    render :new, status: :unprocessable_entity
  end
end

# config/locales/app/controllers/polls/create.en.yml
en:
  polls:
    create:
      success: "Poll created successfully!"
      error: "Failed to create poll. Please check the form for errors."
```

**Best Practices**:
- Use `notice:` for success messages (green alert)
- Use `flash.now[:alert]` for errors with re-render
- Always render with `status: :unprocessable_entity` on validation failure
- Use lazy lookup `t('.key')` for controller i18n
- Test flash messages in request specs

## Summary

All "NEEDS CLARIFICATION" items resolved:

✅ **Nested Attributes**: Using `accepts_nested_attributes_for` with 4 answer fields  
✅ **Answer Uniqueness**: Custom validation with case-insensitive comparison  
✅ **Deadline Validation**: Custom validation ensuring future date with `Time.current`  
✅ **Deadline Input**: HTML5 `datetime_local_field` with browser timezone handling  
✅ **Testing Strategy**: Multi-level testing (model, request, system specs)  
✅ **Authentication**: Devise `authenticate_user!` with association to current_user  
✅ **Flash Messages**: Standard Rails flash with i18n lazy lookup

## Next Steps

Proceed to **Phase 1: Design** to create:
- data-model.md (database schema, associations, validations)
- quickstart.md (development setup instructions)
- Update agent context with Rails nested attributes patterns
