# Phase 1: Data Model - Poll Creation

**Feature**: Poll Creation  
**Branch**: `002-create-poll`  
**Date**: February 11, 2026

## Entity-Relationship Diagram

```
┌─────────────────────┐
│       User          │
│ (from specs/001)    │
│─────────────────────│
│ id: bigint PK       │
│ email: string       │
│ created_at: datetime│
│ updated_at: datetime│
└─────────────────────┘
          │
          │ 1:N (has_many polls)
          ▼
┌─────────────────────┐
│       Poll          │
│─────────────────────│
│ id: bigint PK       │
│ user_id: bigint FK  │◄─────── References users.id
│ question: text      │
│ deadline: datetime  │         (optional, nullable)
│ created_at: datetime│
│ updated_at: datetime│
└─────────────────────┘
          │
          │ 1:N (has_many answers, dependent: destroy)
          ▼
┌─────────────────────┐
│      Answer         │
│─────────────────────│
│ id: bigint PK       │
│ poll_id: bigint FK  │◄─────── References polls.id
│ text: string        │
│ position: integer   │         (1, 2, 3, 4 for ordering)
│ created_at: datetime│
│ updated_at: datetime│
└─────────────────────┘
```

## Schema Definitions

### Polls Table

**Migration**: `db/migrate/[timestamp]_create_polls.rb`

```ruby
class CreatePolls < ActiveRecord::Migration[8.1]
  def change
    create_table :polls do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.text :question, null: false
      t.datetime :deadline, null: true

      t.timestamps
    end

    add_index :polls, :created_at
    add_index :polls, :deadline
  end
end
```

**Schema Details**:
- `id`: Primary key (bigint, auto-increment)
- `user_id`: Foreign key to users table (NOT NULL, indexed)
- `question`: Poll question text (TEXT, NOT NULL)
- `deadline`: Optional deadline for poll closure (DATETIME, NULL)
- `created_at`: Timestamp when poll was created (DATETIME, NOT NULL, indexed)
- `updated_at`: Timestamp when poll was last updated (DATETIME, NOT NULL)

**Indexes**:
- Primary key on `id` (automatic)
- Foreign key index on `user_id` (for joins)
- Index on `created_at` (for listing polls by creation date)
- Index on `deadline` (for querying active/expired polls in future features)

**Constraints**:
- `user_id` MUST be present (foreign key, NOT NULL)
- `question` MUST be present (NOT NULL)
- `deadline` is optional (NULL allowed)
- Foreign key constraint: `user_id` references `users.id` (on_delete: depends on User model cascade rules)

### Answers Table

**Migration**: `db/migrate/[timestamp]_create_answers.rb`

```ruby
class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :poll, null: false, foreign_key: true, index: true
      t.string :text, null: false, limit: 255
      t.integer :position, null: false

      t.timestamps
    end

    add_index :answers, [ :poll_id, :position ], unique: true
  end
end
```

**Schema Details**:
- `id`: Primary key (bigint, auto-increment)
- `poll_id`: Foreign key to polls table (NOT NULL, indexed)
- `text`: Answer option text (STRING(255), NOT NULL)
- `position`: Display order (INTEGER, NOT NULL, 1-4)
- `created_at`: Timestamp when answer was created (DATETIME, NOT NULL)
- `updated_at`: Timestamp when answer was last updated (DATETIME, NOT NULL)

**Indexes**:
- Primary key on `id` (automatic)
- Foreign key index on `poll_id` (for joins)
- Unique compound index on `[poll_id, position]` (ensures each poll has unique positions)

**Constraints**:
- `poll_id` MUST be present (foreign key, NOT NULL)
- `text` MUST be present (NOT NULL, max 255 characters)
- `position` MUST be present (NOT NULL)
- Unique constraint: Each poll can only have one answer at each position (1-4)
- Foreign key constraint: `poll_id` references `polls.id` with `on_delete: cascade`

## Model Definitions

### Poll Model

**File**: `app/models/poll.rb`

```ruby
class Poll < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :answers, dependent: :destroy
  
  # Nested attributes
  accepts_nested_attributes_for :answers, 
    reject_if: :all_blank, 
    allow_destroy: false

  # Validations
  validates :question, presence: true, length: { minimum: 5, maximum: 500 }
  validates :answers, length: { is: 4, message: "must have exactly 4 options" }
  validates :user, presence: true
  
  validate :answers_must_be_unique
  validate :deadline_must_be_in_future, if: :deadline?

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where("deadline IS NULL OR deadline > ?", Time.current) }
  scope :expired, -> { where("deadline IS NOT NULL AND deadline <= ?", Time.current) }

  private

  def answers_must_be_unique
    return if answers.empty?
    
    answer_texts = answers.map { |a| a.text.to_s.downcase.strip }.reject(&:blank?)
    duplicates = answer_texts.select { |text| answer_texts.count(text) > 1 }.uniq
    
    if duplicates.any?
      errors.add(:base, "Answer options must be unique")
    end
  end

  def deadline_must_be_in_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "must be in the future")
    end
  end
end
```

**Associations**:
- `belongs_to :user` - Each poll belongs to one user (creator)
- `has_many :answers, dependent: :destroy` - Each poll has many answers (cascade delete)
- `accepts_nested_attributes_for :answers` - Allows creating answers via poll form

**Validations**:
- `question`: Required, 5-500 characters
- `answers`: Must have exactly 4 answers
- `user`: Required (via belongs_to association)
- Custom: Answers must have unique text (case-insensitive)
- Custom: Deadline must be in future (if provided)

**Scopes**:
- `recent`: Order by creation date (newest first)
- `active`: Polls with no deadline or deadline in future
- `expired`: Polls with deadline in past

### Answer Model

**File**: `app/models/answer.rb`

```ruby
class Answer < ApplicationRecord
  # Associations
  belongs_to :poll

  # Validations
  validates :text, presence: true, length: { minimum: 1, maximum: 255 }
  validates :position, presence: true, 
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 4 }
  validates :poll, presence: true
  
  # Uniqueness of position within poll
  validates :position, uniqueness: { scope: :poll_id }

  # Scopes
  scope :ordered, -> { order(:position) }

  # Instance methods
  def to_s
    text
  end
end
```

**Associations**:
- `belongs_to :poll` - Each answer belongs to one poll

**Validations**:
- `text`: Required, 1-255 characters
- `position`: Required, integer 1-4
- `poll`: Required (via belongs_to association)
- `position`: Must be unique within each poll (database-level unique index)

**Scopes**:
- `ordered`: Order answers by position (1, 2, 3, 4)

**Methods**:
- `to_s`: Returns answer text for display

## Database Constraints Summary

### Foreign Keys
- `polls.user_id` → `users.id` (NOT NULL)
- `answers.poll_id` → `polls.id` (NOT NULL, CASCADE DELETE)

### Unique Constraints
- `answers`: Unique `[poll_id, position]` (each poll has one answer per position)

### Indexes
- `polls.user_id` (foreign key index for joins)
- `polls.created_at` (for sorting/filtering by date)
- `polls.deadline` (for querying active/expired polls)
- `answers.poll_id` (foreign key index for joins)
- `answers.[poll_id, position]` (unique compound index)

### NOT NULL Constraints
- `polls.user_id` (every poll must have a creator)
- `polls.question` (every poll must have a question)
- `answers.poll_id` (every answer must belong to a poll)
- `answers.text` (every answer must have text)
- `answers.position` (every answer must have a position)

### Check Constraints (Application-Level)
- Poll must have exactly 4 answers (validated in Poll model)
- Answer texts must be unique within poll (validated in Poll model)
- Deadline must be in future if provided (validated in Poll model)
- Position must be 1-4 (validated in Answer model)

## Data Integrity Rules

1. **Cascade Delete**: When a poll is deleted, all associated answers are automatically deleted (`dependent: :destroy`)
2. **Orphan Prevention**: Answers cannot exist without a poll (foreign key constraint)
3. **Creator Required**: Polls cannot be created without a user (foreign key constraint)
4. **Answer Count**: Polls must have exactly 4 answers at creation time (model validation)
5. **Position Uniqueness**: Each poll has exactly one answer at each position 1-4 (database unique index)
6. **Answer Uniqueness**: Answer text must be unique within a poll (model validation, case-insensitive)

## Sample Data

```ruby
# Create a poll with 4 answers
user = User.first
poll = Poll.create!(
  user: user,
  question: "What is your favorite programming language?",
  deadline: 1.week.from_now,
  answers_attributes: [
    { text: "Ruby", position: 1 },
    { text: "Python", position: 2 },
    { text: "JavaScript", position: 3 },
    { text: "Go", position: 4 }
  ]
)

# Access answers
poll.answers.ordered  # => [Ruby, Python, JavaScript, Go]

# Check poll status
poll.active?  # => true (deadline in future)

# User's polls
user.polls.recent  # => All user's polls, newest first
```

## Migration Execution

```bash
# Generate migrations
rails generate migration CreatePolls
rails generate migration CreateAnswers

# Run migrations
rails db:migrate

# Verify schema
rails db:schema:dump  # Check db/schema.rb
```

## Testing Data Model

```ruby
# spec/models/poll_spec.rb
RSpec.describe Poll, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:answers).dependent(:destroy) }
    it { should accept_nested_attributes_for(:answers) }
  end

  describe "validations" do
    it { should validate_presence_of(:question) }
    it { should validate_length_of(:question).is_at_least(5).is_at_most(500) }
    
    it "requires exactly 4 answers" do
      poll = build(:poll, answers_attributes: [
        { text: "A", position: 1 },
        { text: "B", position: 2 },
        { text: "C", position: 3 }
      ])
      expect(poll).not_to be_valid
      expect(poll.errors[:answers]).to include(match(/exactly 4/))
    end
    
    it "validates answer uniqueness" do
      poll = build(:poll, answers_attributes: [
        { text: "Same", position: 1 },
        { text: "Same", position: 2 },
        { text: "C", position: 3 },
        { text: "D", position: 4 }
      ])
      expect(poll).not_to be_valid
      expect(poll.errors[:base]).to include(match(/unique/))
    end
    
    it "validates deadline is in future" do
      poll = build(:poll, deadline: 1.day.ago)
      expect(poll).not_to be_valid
      expect(poll.errors[:deadline]).to include(match(/future/))
    end
  end

  describe "scopes" do
    it "returns recent polls first" do
      old_poll = create(:poll, created_at: 2.days.ago)
      new_poll = create(:poll, created_at: 1.day.ago)
      expect(Poll.recent).to eq([new_poll, old_poll])
    end
  end
end

# spec/models/answer_spec.rb
RSpec.describe Answer, type: :model do
  describe "associations" do
    it { should belong_to(:poll) }
  end

  describe "validations" do
    it { should validate_presence_of(:text) }
    it { should validate_length_of(:text).is_at_least(1).is_at_most(255) }
    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than(0).is_less_than_or_equal_to(4) }
    
    it "validates position uniqueness within poll" do
      poll = create(:poll)
      create(:answer, poll: poll, position: 1)
      duplicate = build(:answer, poll: poll, position: 1)
      expect(duplicate).not_to be_valid
    end
  end
end
```

## Next Steps

Proceed to create:
- quickstart.md (development setup instructions)
- Update agent context with Rails nested attributes and validation patterns
- Re-evaluate Constitution Check post-design
