<!--
SYNC IMPACT REPORT - Constitution Update
========================================
Version Change: 1.15.0 → 1.16.0
Type: MINOR (Stimulus/JavaScript interactivity patterns & helper spec enforcement)

Modified Sections:
  - Added new principle: X. Stimulus JavaScript Controllers (No Inline JavaScript)
  - Enhanced Principle II: Test-Driven Development - emphasized helper spec organization

Added Requirements (Principle X):
  - ALL JavaScript interactivity MUST use Stimulus controllers
  - NO inline JavaScript (no onclick, onchange, onsubmit attributes)
  - Controllers in app/javascript/controllers/ following naming convention
  - Use data-controller, data-action, data-target attributes for DOM binding
  - Auto-dismiss patterns (flash messages, notifications) via Stimulus values API
  - Progressive enhancement: JavaScript enhances, doesn't replace server-rendered functionality

Enhanced Requirements (Principle II - Helper Specs):
  - MANDATORY: Helper specs MUST be organized in spec/helpers/[helper_name]/ subdirectory
  - ONE spec file per public method: [method_name]_spec.rb
  - This pattern already existed but is now ENFORCED with explicit examples
  - When generating helpers: MUST generate corresponding spec files following this structure

Directory Structure Added:
  - app/javascript/controllers/[feature]_controller.js for Stimulus controllers
  - spec/helpers/[helper_name]/[method_name]_spec.rb for helper specs (MANDATORY pattern)

Benefits Documented (Principle X):
  - No inline JavaScript (clean HTML, better security via CSP)
  - Reusable controllers across views
  - Testable JavaScript behavior
  - Progressive enhancement (works without JS, enhanced with JS)
  - Auto-cleanup via disconnect() lifecycle (no memory leaks)
  - Configurable behavior via data attributes

Rationale (Principle X):
  Flash messages refactoring revealed need for standardized JavaScript interactivity patterns.
  Inline onclick/onchange handlers violate Content Security Policy (CSP), are hard to test,
  and create maintenance burden. Stimulus provides declarative data attributes for DOM binding,
  lifecycle hooks for cleanup, and values API for configuration. Flash controller demonstrated
  auto-dismiss pattern: data-controller="flash" data-flash-auto-dismiss-value="true"
  data-flash-dismiss-after-value="5000". All JavaScript should follow this pattern for
  consistency, testability, and security.

Rationale (Principle II Enhancement):
  Flash helper spec generation revealed inconsistency in following helper spec organization
  pattern. The pattern (spec/helpers/[helper_name]/[method_name]_spec.rb) exists and is used
  for error_helper but wasn't emphasized enough, leading to flat file generation
  (spec/helpers/flash_helper_spec.rb initially). Making this MANDATORY and adding explicit
  examples prevents future violations.

Template Consistency Status:
  ✅ plan-template.md - No changes required (JavaScript patterns not in planning phase)
  ✅ spec-template.md - No changes required (acceptance criteria unchanged)
  ✅ tasks-template.md - Should add Stimulus controller generation task pattern
  ✅ README.md - Should document Stimulus controller organization
  ✅ templates/commands/implement.md - Should enforce helper spec folder structure

Follow-up TODOs:
  - Update tasks-template.md to include Stimulus controller creation tasks
  - Add README.md section documenting app/javascript/controllers/ organization
  - Update implement command to enforce spec/helpers/[helper_name]/ pattern
  - Consider adding Stimulus controller spec pattern (testing JavaScript controllers)

Previous Update (v1.15.0):
  Added View i18n Management principle requiring config/locales/app/views/ locale files
  for all views with lazy lookup pattern t('.key').
-->

# Rails Poll Voting Constitution

## Core Principles

### I. Rails-First Architecture

All features MUST leverage Rails conventions and built-in capabilities before introducing external dependencies. The Rails Way is the default choice:
- Use Rails generators for scaffolding (models, controllers, migrations)
- Follow MVC pattern strictly: fat models, skinny controllers
- Leverage Active Record for data operations; avoid raw SQL unless performance-critical
- Use Turbo/Hotwire for dynamic interactions (SSR-first, minimal JavaScript)
- Partials and ViewComponents for reusable UI elements
- Background jobs via Active Job (Solid Queue for Rails 8+)

**Rationale**: Rails conventions reduce cognitive load, improve maintainability, and ensure consistency. The framework's maturity means most problems have established patterns.

### II. Test-Driven Development (NON-NEGOTIABLE)

TDD is mandatory for all feature work. Red-Green-Refactor cycle strictly enforced:
1. Write failing test (RSpec system/request/model specs)
2. Get user/stakeholder approval on test scenarios
3. Verify test fails for the right reason
4. Implement minimum code to pass
5. Refactor while keeping tests green

**Testing Framework: RSpec**

This project uses **RSpec** as the primary testing framework. All tests MUST be written in RSpec format:

**Test Types and Coverage Requirements**:
- **Model specs** (`spec/models/`): Validations, associations, scopes, business logic methods
  - MUST test all validations (presence, uniqueness, format, custom)
  - MUST test all associations (belongs_to, has_many, has_one)
  - MUST test public methods and class methods
  - Use Shoulda Matchers for Rails validations (one-liner syntax)
- **Request specs** (`spec/requests/`): Controller actions, HTTP responses, authentication/authorization
  - MUST test all controller actions (GET, POST, PATCH, DELETE)
  - MUST test success and failure scenarios
  - MUST test authentication and authorization logic
  - MUST verify HTTP status codes and redirects
  - MUST test flash messages and error responses
- **System specs** (`spec/system/`): End-to-end user journeys, critical flows
  - MUST test critical user paths (sign-up, login, core features)
  - Use Capybara for browser simulation
  - Test JavaScript interactions when present

**Automatic Spec Generation**:

Rails generators MUST be configured to automatically create RSpec specs:
- `rails generate model` → creates `spec/models/[model]_spec.rb` + `spec/factories/[model].rb`
- `rails generate controller` → creates `spec/requests/[controller]_spec.rb`
- `rails generate scaffold` → creates model, request, and factory specs

Configuration in `config/application.rb`:
```ruby
config.generators do |g|
  g.test_framework :rspec,
    fixtures: false,
    view_specs: false,
    helper_specs: false,
    routing_specs: false,
    request_specs: true,
    controller_specs: false
  g.fixture_replacement :factory_bot, dir: 'spec/factories'
end
```

**When Creating/Updating Code**:

1. **New Models**: Write model spec FIRST before creating migration
   ```bash
   # Create spec file manually or via generator
   rails generate model Poll title:string description:text
   # This creates: spec/models/poll_spec.rb + spec/factories/polls.rb
   ```

2. **New Controllers/Features**: Write request spec FIRST before implementing action
   ```bash
   # Create request spec manually or via generator
   rails generate controller Polls index show new create
   # This creates: spec/requests/polls_spec.rb
   ```

3. **Updating Existing Code**: Update/add specs BEFORE changing implementation
   - If adding validation: Add `it { should validate_presence_of(:field) }` first
   - If adding method: Add `describe '#method_name'` with test cases first
   - If changing behavior: Update specs to reflect new expected behavior first

4. **Every Commit MUST Include**:
   - Code changes AND corresponding spec updates
   - All specs passing (`bundle exec rspec`)
   - No decrease in test coverage

**Test Data Management**:
- **FactoryBot** for creating test objects (replaces fixtures)
- **Faker** for realistic fake data (emails, names, text)
- Factories MUST be defined in `spec/factories/` directory
- Use `build(:model)` for in-memory objects (faster)
- Use `create(:model)` only when database persistence needed
- Use traits for variations: `create(:user, :admin)` or `create(:poll, :expired)`

**Test Helpers and Support**:
- **Shoulda Matchers**: One-liner matchers for Rails validations
  ```ruby
  it { should validate_presence_of(:email) }
  it { should have_many(:polls) }
  ```
- **Database Cleaner**: Clean database state between tests
- **Devise Test Helpers**: `sign_in user` for authentication in request/system specs

**Minimum Coverage Requirements**:
- Models: 95% coverage (validations, associations, methods)
- Controllers/Requests: 90% coverage (all actions, edge cases)
- System: Critical user journeys only (authentication, core features)
- Overall project: minimum 90% coverage

**Running Tests**:
```bash
# Run all specs
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/models/user_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/user_spec.rb:25

# Run with documentation format
bundle exec rspec --format documentation
```

**Test Organization** (`spec/` directory):
```
spec/
├── factories/          # FactoryBot factories for test data
├── models/            # Model unit tests
├── requests/          # Request specs (controller actions, APIs)
├── system/            # End-to-end browser tests (Capybara)
├── helpers/           # Helper method tests (organized by helper module)
│   ├── error_helper/  # ErrorHelper method specs (one file per method)
│   │   ├── field_error_message_spec.rb
│   │   ├── field_icon_color_spec.rb
│   │   └── field_border_classes_spec.rb
│   └── application_helper/  # ApplicationHelper method specs
├── support/           # Shared test configuration
│   ├── database_cleaner.rb
│   ├── factory_bot.rb
│   └── shoulda_matchers.rb
├── rails_helper.rb    # Rails-specific RSpec configuration
└── spec_helper.rb     # General RSpec configuration
```

**Helper Spec Organization Pattern**:

Helper specs MUST be organized by helper module with one spec file per public method:
- Create subdirectory: `spec/helpers/[helper_name]/`
- One spec file per public method: `[method_name]_spec.rb`
- Each file tests ONE method only (focused, single responsibility)

Example for `ErrorHelper` with 3 public methods:
```
spec/helpers/error_helper/
├── field_error_message_spec.rb    # Tests #field_error_message only
├── field_icon_color_spec.rb       # Tests #field_icon_color only
└── field_border_classes_spec.rb   # Tests #field_border_classes only
```

Each spec file structure:
```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorHelper, type: :helper do
  describe '#method_name' do
    let(:resource) { User.new }

    context 'when [condition]' do
      it 'returns [expected result]' do
        # Test cases
      end
    end

    context 'with different field names' do
      # Test method works with various inputs
    end
  end
end
```

**Benefits**:
- Easy to locate tests for specific helper method
- Faster test runs when working on single method (run one file)
- Clear ownership: each file maps 1:1 with public method
- Simplified pull requests: method changes affect single spec file
- Better git history: method-specific commits touch only relevant spec file

**Rationale**: Tests are executable specifications. Writing them first ensures we build what's needed, not what's easy. Early validation prevents costly rewrites. RSpec's BDD-style syntax creates self-documenting tests that serve as living documentation. Automatic spec generation via Rails generators ensures tests are written alongside code, not as an afterthought. FactoryBot and Shoulda Matchers reduce boilerplate and improve test readability. Organizing helper specs by method improves maintainability and follows single responsibility principle at the file level.

### III. SSR Performance & User Experience

Server-side rendering is the primary delivery mechanism. Performance budgets enforced:
- Time to First Byte (TTFB): < 200ms (p95)
- Largest Contentful Paint (LCP): < 2.5s
- First Input Delay (FID): < 100ms
- Cumulative Layout Shift (CLS): < 0.1

**Implementation requirements**:
- Fragment caching for expensive partials (Russian Doll caching)
- Database query optimization: eager loading (N+1 prevention), proper indexes
- Turbo Frames for isolated updates without full page reload
- Progressive enhancement: full functionality without JavaScript
- Responsive design mobile-first (Tailwind CSS preferred)

**Rationale**: SSR ensures fast initial page loads, better SEO, and accessibility. Performance directly impacts user satisfaction and retention.

### IV. Security by Default

Security is built-in, not bolted-on. Rails security features MUST be enabled:
- Strong parameters for all controller inputs (no mass assignment)
- CSRF protection enabled (verify_authenticity_token)
- Content Security Policy headers configured
- SQL injection prevention via parameterized queries/Active Record
- XSS prevention via automatic HTML escaping in ERB
- Authentication via Devise or Rails built-in has_secure_password
- Authorization via Pundit or Action Policy (explicit policies)

**Additional requirements**:
- Secrets managed via Rails credentials (encrypted)
- HTTPS enforced in production (force_ssl = true)
- Rate limiting on public endpoints (Rack::Attack)
- Regular dependency updates (bundle audit, brakeman scans)

**Rationale**: Security breaches destroy trust. Prevention is orders of magnitude cheaper than remediation.

### V. Simplicity & Maintainability

Start with the simplest solution that works. Complexity requires explicit justification:
- YAGNI: Don't build features until they're needed
- Convention over configuration: use Rails defaults unless strong reason to deviate
- Single Responsibility Principle: classes/methods do one thing well
- Avoid premature optimization: measure before optimizing
- Code review focus: "Can a Rails developer unfamiliar with this feature understand it?"

**Complexity triggers (require architectural review)**:
- Adding new gems (must justify over Rails built-in)
- Introducing services/patterns not in core Rails (e.g., Command pattern, Event Sourcing)
- Custom middleware or Rack apps
- Multi-database configurations
- Background job complexity beyond simple enqueue/perform

**Rationale**: Simple code is maintainable code. Rails' sweet spot is conventional applications; fighting the framework creates maintenance debt.

### VI. User-Centric Error Handling & Validation UX

All forms and user inputs MUST provide clear, actionable error feedback following established UX patterns:

**Validation Error Display Requirements**:
- **Inline field errors**: Display error messages directly below invalid input fields
- **Visual indicators**: Highlight invalid fields with red border (`border-red-500`)
- **Icon feedback**: Change field icons to red when validation fails (`text-red-400`)
- **Error text color**: Use Tailwind red variants available in v4 (`text-red-700`, not `text-red-600`)
- **Focus state consistency**: Invalid fields maintain red border on focus (no color switching)
- **No focus ring overlap**: Remove `focus:ring-2` on error states to prevent black ring fallback

**Notification Pattern** (Tailwind Notifications style):
- **Position**: Fixed top-right corner (`fixed top-4 right-4 z-50`)
- **Summary message**: Display error count and resource name (e.g., "1 error prohibited this user from being saved")
- **Error list**: Show up to 3 specific errors in notification; full list via inline field errors
- **Dismissible**: Include close button with accessible label (`sr-only`)
- **Visual hierarchy**: 
  - Warning icon (red) for error notifications
  - White background with ring shadow (`ring-1 ring-black ring-opacity-5`)
  - Professional spacing and typography

**Implementation Standards**:
```erb
<!-- Top-right notification for form errors -->
<% if resource.errors.any? %>
  <div class="fixed top-4 right-4 z-50 max-w-md">
    <div class="bg-white rounded-lg shadow-lg pointer-events-auto ring-1 ring-black ring-opacity-5">
      <!-- Error summary with dismissible close button -->
    </div>
  </div>
<% end %>

<!-- Inline field error example -->
<%= f.email_field :email,
    class: "#{resource.errors[:email].any? ? 'border-red-500 focus:border-red-500' : 'border-gray-300 focus:ring-indigo-500 focus:ring-2'}" %>
<% if resource.errors[:email].any? %>
  <p class="mt-1 text-sm text-red-700"><%= resource.errors[:email].first %></p>
<% end %>
```

**Consistency Requirements**:
- All forms (authentication, resource creation/editing) use identical error pattern
- Flash messages for non-form errors (login failures, authorization) use layout notification area
- Progressive enhancement: errors work without JavaScript
- Server-side validation primary; client-side optional enhancement only

**Tailwind v4 Color Constraints**:
- ONLY use red variants that exist in generated CSS: `text-red-400`, `text-red-500`, `text-red-700`, `text-red-800`, `border-red-500`
- Avoid `text-red-600` (not generated in Tailwind v4, renders as black)
- Check `app/assets/builds/tailwind.css` for available color utilities before use

**Rationale**: Consistent, clear error feedback reduces user frustration and form abandonment. Inline field errors provide immediate, actionable guidance at the point of error. Top-right notifications give global context without blocking form content. This pattern balances visibility with usability, following established UX best practices from Tailwind UI and modern web applications. Tailwind v4's on-demand class generation requires explicit verification of color utility availability to prevent styling bugs.

### VII. Gem Internationalization (i18n) Management

When installing gems that include internationalization (i18n) files, locale files MUST be copied from the gem's GitHub repository to the project's `config/locales/gems/` directory for version control and customization.

**Requirements**:
- **Directory organization**: `config/locales/gems/[gem_name]/`
  - Rails core: `config/locales/gems/rails/` (actionview, activemodel, activerecord, activesupport)
  - Third-party gems: `config/locales/gems/devise/`, `config/locales/gems/pundit/`, etc.
- **Source**: Official GitHub repository at tagged version matching installed gem
  - Example: Rails 8.1.2 → `https://raw.githubusercontent.com/rails/rails/v8.1.2/[component]/lib/[component]/locale/en.yml`
  - Example: Devise 4.9.0 → `https://raw.githubusercontent.com/heartcombo/devise/v4.9.0/config/locales/en.yml`
- **Files**: Download ALL locale files for the gem
  - Minimum: `en.yml` (English)
  - Optional: Additional languages if project supports them (`es.yml`, `fr.yml`, etc.)
- **Rails core components**: Use separate files for each component
  - `actionview.en.yml` - Form helpers, datetime formatting, distance_in_words
  - `activemodel.en.yml` - Model validation error messages
  - `activerecord.en.yml` - ActiveRecord-specific error messages
  - `activesupport.en.yml` - Date/time formatting, number formatting, array helpers
- **Version control**: Locale files MUST be committed to git (NOT ignored)
- **Documentation**: Update README.md with process for updating locale files during gem upgrades

**Implementation Process**:
```bash
# Create directory for gem locale files
mkdir -p config/locales/gems/rails

# Download Rails 8.1.2 locale files from GitHub
curl -o config/locales/gems/rails/actionview.en.yml \
  https://raw.githubusercontent.com/rails/rails/v8.1.2/actionview/lib/action_view/locale/en.yml

curl -o config/locales/gems/rails/activemodel.en.yml \
  https://raw.githubusercontent.com/rails/rails/v8.1.2/activemodel/lib/active_model/locale/en.yml

curl -o config/locales/gems/rails/activerecord.en.yml \
  https://raw.githubusercontent.com/rails/rails/v8.1.2/activerecord/lib/active_record/locale/en.yml

curl -o config/locales/gems/rails/activesupport.en.yml \
  https://raw.githubusercontent.com/rails/rails/v8.1.2/activesupport/lib/active_support/locale/en.yml

# For third-party gems (e.g., Devise)
mkdir -p config/locales/gems/devise
curl -o config/locales/gems/devise/en.yml \
  https://raw.githubusercontent.com/heartcombo/devise/v4.9.0/config/locales/en.yml
```

**Configuration Requirements**:

Rails i18n configuration MUST include recursive locale loading to load gem files:
```ruby
# config/application.rb
config.i18n.default_locale = :en
config.i18n.available_locales = [:en]
config.i18n.fallbacks = true
config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
```

**Locale File Organization**:
```
config/locales/
├── en.yml                          # Application-specific translations
├── devise.en.yml                   # Devise overrides (optional)
└── gems/
    ├── rails/                      # Rails core locale files
    │   ├── actionview.en.yml
    │   ├── activemodel.en.yml
    │   ├── activerecord.en.yml
    │   └── activesupport.en.yml
    ├── devise/                     # Devise locale files
    │   └── en.yml
    └── [other_gems]/               # Additional gem locale files
```

**Benefits**:
- **Version control**: Track changes to i18n files across gem upgrades
- **Customization**: Modify translations without monkey-patching gem internals
- **Offline development**: No runtime dependency on gem load paths
- **Explicit visibility**: Know exactly what translations are available
- **Consistency**: Production uses exact translations as dev/test environments
- **Review process**: Locale changes visible in git diffs during gem upgrades
- **Debugging**: Easy to locate translation keys and values

**Gem Upgrade Process**:
1. Check gem version in `Gemfile.lock` after `bundle update [gem_name]`
2. Download new locale files from GitHub at matching tag/version
3. Review diff (`git diff config/locales/gems/[gem_name]/`) for translation changes
4. Test application to ensure translations work correctly
5. Commit locale file updates with gem version bump

**Rationale**: Gems include locale files in their load paths, but these aren't tracked in version control or easily customizable. Copying from GitHub to `config/locales/gems/` ensures explicit control over all user-facing text and supports i18n best practices. This pattern applies to Rails core components (actionview, activemodel, activerecord, activesupport) and third-party gems (Devise, Pundit, etc.). Directory organization keeps gem locale files separate from application-specific translations (`config/locales/en.yml`), improving maintainability and reducing merge conflicts during gem upgrades.

### VIII. Application Model Internationalization (i18n) Management

When creating or updating models in `app/models/`, corresponding i18n locale files MUST be created/updated in `config/locales/app/models/` to provide human-readable model and attribute names.

**Requirements**:
- **Directory organization**: `config/locales/app/models/[model_name].en.yml`
  - Example: User model → `config/locales/app/models/user.en.yml`
  - Example: Poll model → `config/locales/app/models/poll.en.yml`
  - Example: Vote model → `config/locales/app/models/vote.en.yml`
- **Model names**: Include singular and plural forms under `activerecord.models`
- **Attributes**: Include ALL attributes under `activerecord.attributes.[model_name]`
  - Database columns (id, email, created_at, updated_at, etc.)
  - Virtual attributes (password, password_confirmation, current_password, remember_me)
  - Association names (author, comments, votes, etc.)
- **Namespace convention**: Follow Rails i18n standards
  ```yaml
  en:
    activerecord:
      models:
        user:
          one: User
          other: Users
      attributes:
        user:
          email: Email
          password: Password
  ```
- **i18n Spec Requirement**: Create/update `spec/models/[model_name]/i18n_spec.rb`
  - Test model name translations (singular and plural)
  - Test ALL attribute name translations
  - One test per attribute verifying `Model.human_attribute_name(:attribute)`
  - Follows model spec organization pattern (one file per concern)
- **Synchronization**: Update locale file AND i18n spec when adding/removing/renaming model attributes
- **Commit together**: Model changes, locale file updates, and i18n spec in same PR/commit
- **Version control**: Locale files and specs MUST be committed to git

**Implementation Process**:
```bash
# When creating User model
rails generate model User email:string

# Immediately create locale file
mkdir -p config/locales/app/models
touch config/locales/app/models/user.en.yml

# Add translations for model name and all attributes

# Create i18n spec
touch spec/models/user/i18n_spec.rb

# Add tests for model name and attribute translations
```

**Model Locale File Template**:
```yaml
en:
  activerecord:
    models:
      [model_name]:
        one: [Singular Name]
        other: [Plural Name]
    
    attributes:
      [model_name]:
        # Database columns
        id: ID
        created_at: Created at
        updated_at: Updated at
        
        # Model-specific attributes
        [attribute_1]: [Human-readable label]
        [attribute_2]: [Human-readable label]
        
        # Virtual attributes (if applicable)
        # password: Password
        # password_confirmation: Password confirmation
```

**Example - User Model**:
```yaml
en:
  activerecord:
    models:
      user:
        one: User
        other: Users
    
    attributes:
      user:
        email: Email
        password: Password
        password_confirmation: Password confirmation
        current_password: Current password
        remember_me: Remember me
        created_at: Created at
        updated_at: Updated at
```

**Usage in Application**:
```ruby
# In views/forms
User.model_name.human           # => "User"
User.model_name.human.pluralize # => "Users"
User.human_attribute_name(:email) # => "Email"

# In error messages (automatically used by Rails)
# "Email can't be blank" instead of "email can't be blank"
```

**Locale File Organization**:
```
config/locales/
├── en.yml                          # Global application translations
├── app/                            # Application-specific translations
│   └── models/                     # Model translations
│       ├── user.en.yml
│       ├── poll.en.yml
│       └── vote.en.yml
└── gems/                           # Gem locale files
    ├── rails/                      # Rails core
    │   ├── actionview.en.yml
    │   ├── activemodel.en.yml
    │   ├── activerecord.en.yml
    │   └── activesupport.en.yml
    └── devise/                     # Third-party gems
        └── en.yml

spec/models/
└── [model_name]/
    ├── i18n_spec.rb                # i18n translation tests
    ├── validations_spec.rb
    └── ...
```

**i18n Spec Template**:
```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'i18n translations' do
    describe 'model name' do
      it 'returns translated singular model name' do
        expect(User.model_name.human).to eq('User')
      end

      it 'returns translated plural model name' do
        expect(User.model_name.human.pluralize).to eq('Users')
      end
    end

    describe 'attribute names' do
      it 'returns translated email attribute' do
        expect(User.human_attribute_name(:email)).to eq('Email')
      end

      # Add one test per attribute
    end
  end
end
```

**Benefits**:
- **Centralized translations**: All model attribute labels in one place per model
- **Human-readable errors**: Validation errors use proper capitalization and formatting
- **Consistent terminology**: Same attribute labels across forms, tables, and error messages
- **Easy customization**: Change labels without modifying view/form code
- **Multi-language ready**: Add es.yml, fr.yml files later for internationalization
- **Rails integration**: Automatic usage in form labels, error messages, and model helpers
- **Maintainability**: Clear mapping between models and their translations
- **Test coverage**: i18n specs ensure translations are defined and correct
- **Prevent regressions**: Tests catch missing/incorrect translations before runtime

**Maintenance Workflow**:
1. Add new attribute to model (migration + model file)
2. Update `config/locales/app/models/[model].en.yml` with new attribute translation
3. Update `spec/models/[model]/i18n_spec.rb` with new attribute test
4. Run specs to verify translation works
5. Commit model changes, locale file, and i18n spec together
6. Review: ensure all attributes have human-readable labels and passing tests

**Rationale**: Rails i18n supports model and attribute name translation via `activerecord.models` and `activerecord.attributes`, but requires explicit locale files. Creating `config/locales/app/models/xxx.en.yml` per model ensures all attribute names are translatable, improving user-facing error messages and form labels. Adding `spec/models/xxx/i18n_spec.rb` ensures translations are defined correctly and prevents runtime errors from missing translations. Tests serve as documentation for expected attribute labels and catch regressions during locale file updates. Separating application-specific (`app/`) from gem-specific (`gems/`) locale files improves organization and prevents mixing concerns. This pattern aligns with Rails i18n best practices and supports future multi-language requirements without code changes.

### IX. Application View Internationalization (i18n) Management

When creating or updating views in `app/views/`, corresponding i18n locale files MUST be created/updated in `config/locales/app/views/` to provide translations for all user-facing text.

**Requirements**:
- **Directory organization**: `config/locales/app/views/[path]/[view_name].en.yml`
  - Mirrors `app/views/` directory structure
  - Example: `app/views/devise/sessions/new.html.erb` → `config/locales/app/views/devise/sessions/new.en.yml`
  - Example: `app/views/polls/index.html.erb` → `config/locales/app/views/polls/index.en.yml`
- **Content**: Include ALL user-facing text
  - Page titles and headings
  - Button labels and link text
  - Form labels and placeholders
  - Helper text and instructions
  - Success/error messages specific to the view
- **Lazy lookup pattern**: Use `t('.key')` instead of full path
  - Rails automatically infers full key from view path
  - Example: In `app/views/devise/sessions/new.html.erb`, `t('.title')` resolves to `devise.sessions.new.title`
  - Shorter, more maintainable than `t('devise.sessions.new.title')`
- **Synchronization**: Update locale file when adding/removing/changing user-facing text in views
- **Commit together**: View changes and locale file updates in same PR/commit
- **Version control**: Locale files MUST be committed to git

**Implementation Process**:
```bash
# When creating devise/sessions/new.html.erb
# Immediately create corresponding locale file
mkdir -p config/locales/app/views/devise/sessions
touch config/locales/app/views/devise/sessions/new.en.yml

# Add all user-facing text translations
```

**View Locale File Template**:
```yaml
en:
  [controller]:
    [action]:
      [view_name]:
        title: "[Page Title]"
        subtitle: "[Subtitle or Description]"
        button_name: "[Button Text]"
        field_placeholder: "[Placeholder Text]"
        # Add all user-facing strings
```

**Example - Devise Sessions New View**:
```yaml
# config/locales/app/views/devise/sessions/new.en.yml
en:
  devise:
    sessions:
      new:
        title: "Welcome Back"
        subtitle: "Sign in to continue to your account"
        submit_button: "Log in"
        email_placeholder: "you@example.com"
        password_placeholder: "••••••••"
```

**Usage in Views** (Lazy Lookup):
```erb
<!-- app/views/devise/sessions/new.html.erb -->
<h2><%= t('.title') %></h2>
<p><%= t('.subtitle') %></p>
<%= f.submit t('.submit_button') %>
<%= f.email_field :email, placeholder: t('.email_placeholder') %>
```

**Locale File Organization**:
```
config/locales/
├── en.yml                          # Global application translations
├── app/
│   ├── models/                     # Model translations
│   │   ├── user.en.yml
│   │   └── poll.en.yml
│   └── views/                      # View translations (mirrors app/views/)
│       ├── devise/
│       │   ├── sessions/
│       │   │   └── new.en.yml
│       │   └── registrations/
│       │       ├── new.en.yml
│       │       └── edit.en.yml
│       └── polls/
│           ├── index.en.yml
│           ├── show.en.yml
│           └── new.en.yml
└── gems/                           # Gem locale files
    ├── rails/
    └── devise/
```

**Benefits**:
- **Centralized view text**: All user-facing strings in one place per view
- **Easy localization**: Add `.es.yml`, `.fr.yml` files for multi-language support
- **DRY code**: No hardcoded strings in views
- **Consistent wording**: Reuse translations across views via shared keys
- **Lazy lookup**: Reduces verbosity (`t('.title')` vs `t('devise.sessions.new.title')`)
- **Maintainability**: Clear 1:1 mapping between views and their translations
- **Refactoring safety**: Change wording without touching view code
- **Designer-friendly**: Non-technical team members can update copy in YAML files

**Maintenance Workflow**:
1. Add/modify text in view template
2. Update `config/locales/app/views/[path]/[view].en.yml` with new/changed translations
3. Use lazy lookup `t('.key')` in view
4. Verify translation displays correctly
5. Commit view and locale file together
6. Review: ensure no hardcoded strings remain in view

**Rationale**: Hardcoded strings in views make localization difficult and create maintenance burden when copy changes. Rails i18n supports lazy lookup (`t('.key')`) which automatically infers full key from view path, reducing verbosity and improving maintainability. Creating `config/locales/app/views/[path]/[view].en.yml` per view ensures all user-facing text is translatable. Mirroring `app/views/` directory structure in `config/locales/app/views/` maintains clear 1:1 mapping and makes locale files easy to find. This pattern aligns with Rails i18n best practices and supports future multi-language requirements without code changes.

---

### X. Stimulus JavaScript Controllers (No Inline JavaScript)

ALL JavaScript interactivity MUST be implemented using Stimulus controllers. Inline JavaScript (onclick, onchange, onsubmit, etc.) is PROHIBITED.

**Requirements**:
- **No inline JavaScript**: Never use `onclick`, `onchange`, `onsubmit`, or any inline event handlers
- **Stimulus controllers only**: All JavaScript behavior via `app/javascript/controllers/[feature]_controller.js`
- **Declarative data attributes**: Use `data-controller`, `data-action`, `data-[controller]-target` for DOM binding
- **Progressive enhancement**: JavaScript enhances server-rendered functionality, doesn't replace it
- **Lifecycle management**: Use `connect()` for initialization, `disconnect()` for cleanup

**Controller Organization**:
```
app/javascript/controllers/
├── flash_controller.js        # Flash message auto-dismiss & manual close
├── form_controller.js         # Form validation, dynamic fields
├── modal_controller.js        # Modal open/close behavior
└── dropdown_controller.js     # Dropdown toggle behavior
```

**Naming Convention**:
- File: `[feature]_controller.js` (snake_case)
- Class: `export default class extends Controller`
- Data controller: `data-controller="[feature]"` (matches filename without `_controller.js`)

**Controller Structure Template**:
```javascript
// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]  // DOM element references
  static values = {              // Configurable values via data attributes
    autoDismiss: { type: Boolean, default: true },
    dismissAfter: { type: Number, default: 5000 }
  }

  connect() {
    // Initialization logic (runs when controller attached to DOM)
    if (this.autoDismissValue) {
      this.timeout = setTimeout(() => this.dismiss(), this.dismissAfterValue)
    }
  }

  disconnect() {
    // Cleanup logic (runs when controller removed from DOM)
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    // Action methods (called via data-action)
    this.element.remove()
  }
}
```

**View Integration** (Declarative Data Attributes):
```erb
<!-- ❌ WRONG: Inline JavaScript -->
<button onclick="this.parentElement.remove()">Close</button>

<!-- ✅ CORRECT: Stimulus Controller -->
<div data-controller="flash" 
     data-flash-auto-dismiss-value="true" 
     data-flash-dismiss-after-value="5000">
  <p data-flash-target="message">Flash message content</p>
  <button data-action="click->flash#dismiss">Close</button>
</div>
```

**Common Patterns**:

1. **Auto-dismiss with configurable timeout** (Flash messages, notifications):
```javascript
static values = { dismissAfter: { type: Number, default: 5000 } }

connect() {
  this.timeout = setTimeout(() => this.dismiss(), this.dismissAfterValue)
}

disconnect() {
  if (this.timeout) clearTimeout(this.timeout)
}

dismiss() {
  this.element.remove()
}
```

2. **Toggle visibility** (Modals, dropdowns):
```javascript
toggle() {
  this.element.classList.toggle("hidden")
}

close() {
  this.element.classList.add("hidden")
}
```

3. **Form validation** (Dynamic field validation):
```javascript
static targets = ["field", "error"]

validate() {
  const isValid = this.fieldTarget.value.length > 0
  this.errorTarget.classList.toggle("hidden", isValid)
}
```

**Values API** (Configuration via data attributes):
```erb
<!-- Boolean values -->
<div data-controller="flash" data-flash-auto-dismiss-value="false">

<!-- Number values -->
<div data-controller="flash" data-flash-dismiss-after-value="3000">

<!-- String values -->
<div data-controller="modal" data-modal-size-value="large">

<!-- Array values -->
<div data-controller="carousel" data-carousel-slides-value='["slide1", "slide2"]'>

<!-- Object values -->
<div data-controller="map" data-map-options-value='{"zoom": 12, "center": [0, 0]}'>
```

**Testing Stimulus Controllers** (Future requirement):
- System specs (Capybara) test JavaScript behavior in integration tests
- Consider adding controller-specific JavaScript unit tests when complex logic exists

**Benefits**:
- **Clean HTML**: No inline JavaScript, easier to read and maintain
- **Security**: Supports Content Security Policy (CSP) - no inline script execution
- **Reusability**: Controllers can be reused across multiple views
- **Testable**: Stimulus controllers can be unit tested (JavaScript tests)
- **Progressive enhancement**: Server renders HTML, JavaScript enhances it
- **Lifecycle management**: `disconnect()` prevents memory leaks (cleanup timers, listeners)
- **Configurable**: Values API allows customization via data attributes without code changes

**Flash Message Example** (Complete Implementation):

**Controller** (`app/javascript/controllers/flash_controller.js`):
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: true },
    dismissAfter: { type: Number, default: 5000 }
  }

  connect() {
    if (this.autoDismissValue) {
      this.timeout = setTimeout(() => this.dismiss(), this.dismissAfterValue)
    }
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.remove()
  }
}
```

**Partial** (`app/views/layouts/_flash.html.erb`):
```erb
<div class="fixed top-4 right-4 z-50 max-w-md">
  <% flash.each do |type, message| %>
    <% styles = flash_styles(type) %>
    <div data-controller="flash" 
         class="bg-white <%= styles[:border_color] %> border-l-4 shadow-lg rounded-lg p-4 mb-4"
         role="alert">
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 <%= styles[:icon_color] %>" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="<%= styles[:icon_path] %>" clip-rule="evenodd"/>
          </svg>
        </div>
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-gray-900"><%= message %></p>
        </div>
        <button data-action="click->flash#dismiss" 
                type="button" 
                class="ml-4 flex-shrink-0 text-gray-400 hover:text-gray-600">
          <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
          </svg>
        </button>
      </div>
    </div>
  <% end %>
</div>
```

**Usage**:
```ruby
# Controller action
redirect_to root_path, notice: "Successfully logged in"
redirect_to root_path, alert: "Invalid credentials"
redirect_to root_path, flash: { warning: "Session expiring soon" }
```

**Result**:
- Flash message appears with appropriate styling (green/red/yellow/blue)
- Auto-dismisses after 5 seconds (configurable via `data-flash-dismiss-after-value`)
- Can disable auto-dismiss: `data-flash-auto-dismiss-value="false"`
- Manual close via X button (`data-action="click->flash#dismiss"`)
- Clean separation: Helper for styling, Stimulus for behavior, view for structure

**Rationale**: Inline JavaScript (onclick, onchange) violates Content Security Policy (CSP), making applications vulnerable to XSS attacks. Inline handlers are hard to test, difficult to reuse, and create maintenance burden. Stimulus provides declarative data attributes for DOM binding (`data-action="click->flash#dismiss"`), lifecycle hooks for cleanup (`disconnect()` clears timers), and values API for configuration (`data-flash-dismiss-after-value="5000"`). All JavaScript should follow this pattern for consistency, testability, security, and maintainability. Flash message refactoring demonstrated the pattern: auto-dismiss via Stimulus values API, manual close via data-action, and proper cleanup in disconnect() lifecycle hook.

---

## Technology Stack

**Core**:
- Ruby 4.0+ (latest stable)
- Rails 8.0+ (leveraging Solid Queue, Solid Cache, Solid Cable)
- PostgreSQL 15+ (primary database)
- Redis 7+ (caching, session store)

**Frontend**:
- Hotwire (Turbo + Stimulus) for SPA-like interactions
- Tailwind CSS 4+ for styling (MUST use official patterns from https://tailwindcss.com/)
- ViewComponent for reusable UI components
- Importmap for JavaScript dependencies (no build step unless unavoidable)

**Testing**:
- **RSpec** (system, request, model specs) - BDD testing framework
- **FactoryBot** for test data generation (replaces fixtures)
- **Faker** for realistic fake data generation
- **Shoulda Matchers** for Rails validation testing (one-liner matchers)
- **Database Cleaner** for clean database state between tests
- **Capybara** for system/browser testing
- **Selenium WebDriver** for JavaScript testing
- **SimpleCov** for coverage tracking (minimum 90% required)

**Development**:
- Rubocop with Rails cops (style enforcement)
- Brakeman (security scanning)
- Bullet (N+1 detection)
- bundler-audit (dependency vulnerability checks)

**Deployment**:
- Render.com (managed platform - PostgreSQL, Redis, web services)
- Native buildpacks (no Docker required)
- GitHub integration for automatic deployments
- GitHub Actions for CI/CD pipeline

## Development Standards

**Code Quality Gates** (must pass before merge):
1. All tests passing (RSpec suite green)
2. Rubocop violations: zero
3. Brakeman warnings: zero (or explicitly documented exceptions)
4. Coverage: minimum 90% on new/changed code
5. PR review: minimum one approval from maintainer

**Workflow**:
- Feature branches: `###-feature-name` (issue number prefix)
- Commits: MUST follow format `[specs#xxx][tasks#yyy] type: description`
  - `xxx`: Spec number (e.g., 001 for specs/001-user-signup/)
  - `yyy`: Task number (e.g., 054 for T054)
  - `type`: Conventional commit type (`feat`, `fix`, `refactor`, `test`, `docs`)
  - Example: `[specs#001][tasks#054] test: add User model validation tests`
  - Exception: Infrastructure/non-spec commits use conventional format only
- PRs: include spec reference, test coverage, migration plan if applicable
- Database migrations: reversible, tested in Render preview environments before production
- Deployment: Automatic on merge to `main` (via Render.com GitHub integration)

**Environment Configuration**:
- All configuration via environment variables (12-factor app)
- .env.example MUST be kept up-to-date with all required/optional variables
- README.md MUST be updated whenever:
  - New environment variables added that affect local development
  - Third-party services integrated (Redis, PostgreSQL, APIs, etc.)
  - Configuration steps change for local setup
  - Prerequisites change (Ruby version, system dependencies)
- Secrets NEVER committed to source control (use Rails credentials or ENV)
- Required variables for production:
  - DATABASE_URL (Render.com auto-provided)
  - REDIS_URL (Render.com auto-provided)
  - RAILS_MASTER_KEY or Rails credentials
  - RAILS_ENV=production
  - RAILS_LOG_LEVEL (info or warn recommended)
- Security variables:
  - RAILS_FORCE_SSL=true (production)
  - RACK_ATTACK configuration for rate limiting
- Feature-specific variables documented in .env.example

**Documentation Requirements**:
- README.md MUST be updated (NON-NEGOTIABLE):
  - When environment variables added/changed (.env.example + README Quick Start)
  - When third-party services integrated (add to Prerequisites, Troubleshooting)
  - When setup steps change (database, Redis, background jobs)
  - When new dependencies require local installation
  - All updates MUST maintain accuracy of Quick Start section
- README updated for new user-facing features
- Inline comments for non-obvious business logic
- API documentation via RDoc for public methods
- Database schema maintained (schema.rb automatically tracked)
- .env.example updated when new environment variables introduced

**UI Standards**:
- All screens MUST use official Tailwind CSS patterns from https://tailwindcss.com/
- Reference Tailwind documentation for forms, layouts, and components
- Prohibited: Custom gradients, animations, or utility classes not in official Tailwind CSS
- Prefer semantic Tailwind utilities: `ring-*` for focus states, `leading-*` for spacing
- Follow mobile-first responsive design with Tailwind breakpoints (`sm:`, `md:`, `lg:`, `xl:`)
- Form validation styling MUST use Tailwind's alert/error patterns
- Authentication pages (login, signup, password reset) MUST follow official form examples

**Rationale**: Official Tailwind patterns are community-tested for accessibility, responsive design, and browser compatibility. Custom implementations create maintenance debt and design inconsistencies. The tailwindcss.com documentation provides battle-tested components that align with modern UI/UX best practices.

## Governance

This constitution supersedes all ad-hoc practices. When in doubt, constitution rules.

**Amendment Process**:
1. Propose change via issue (include rationale, migration plan)
2. Team discussion (minimum 3 business days for feedback)
3. Approval requires consensus (all maintainers agree or no blocking objections)
4. Update constitution version (semantic versioning)
5. Update dependent templates/docs within same PR
6. Add entry to Version History section with date, version, changes, and rationale
7. Announce change in team channel with migration timeline

**Compliance**:
- All PRs reviewed for constitutional alignment
- Quarterly constitution review (identify outdated sections)
- Exceptions require written justification and expiration date
- Automated checks where possible (Rubocop, Brakeman, CI gates)

**Runtime Guidance**:
- Developers consult `.specify.specify/memory/constitution.md` for project-specific rules
- Template commands reference constitution for validation gates
- Onboarding checklist includes constitution review

**Current Version**: 1.15.0 | **Ratified**: 2026-02-10 | **Last Amended**: 2026-02-11

---

## Version History

### Version 1.16.0 - 2026-02-11
**Type**: MINOR (Stimulus JavaScript interactivity patterns & helper spec enforcement)

**Changes**:
- Added new principle: X. Stimulus JavaScript Controllers (No Inline JavaScript)
- Prohibited ALL inline JavaScript (onclick, onchange, onsubmit, etc.)
- Established requirements for Stimulus controllers:
  - All JavaScript behavior via app/javascript/controllers/[feature]_controller.js
  - Declarative data attributes: data-controller, data-action, data-target
  - Progressive enhancement: JavaScript enhances server-rendered functionality
  - Lifecycle management: connect() for initialization, disconnect() for cleanup
- Added controller organization structure and naming conventions:
  - File: [feature]_controller.js (snake_case)
  - Class: export default class extends Controller
  - Data controller: data-controller="[feature]"
- Added controller structure template with targets, values, lifecycle hooks
- Added view integration examples (WRONG: onclick vs CORRECT: data-action)
- Added common patterns: auto-dismiss, toggle visibility, form validation
- Added Values API examples (Boolean, Number, String, Array, Object values)
- Added complete flash message implementation example:
  - flash_controller.js with auto-dismiss and configurable timeout
  - _flash.html.erb partial using data-controller and data-action
  - FlashHelper for styling logic
  - Clean separation: Helper for styling, Stimulus for behavior, view for structure
- Listed benefits: clean HTML, CSP security, reusability, testability, progressive enhancement, lifecycle management, configurability
- Enhanced Principle II (Test-Driven Development):
  - MANDATORY: Helper specs MUST be organized in spec/helpers/[helper_name]/ subdirectory
  - ONE spec file per public method: [method_name]_spec.rb
  - Emphasized existing pattern with explicit examples from error_helper
  - Added requirement for generators to follow this structure

**Rationale**: Flash messages refactoring revealed need for standardized JavaScript interactivity patterns. Inline onclick/onchange handlers violate Content Security Policy (CSP), are hard to test, and create maintenance burden. Stimulus provides declarative data attributes for DOM binding, lifecycle hooks for cleanup, and values API for configuration. Flash controller demonstrated auto-dismiss pattern with configurable timeout. All JavaScript should follow this pattern for consistency, testability, and security. Helper spec organization pattern (spec/helpers/[helper_name]/[method_name]_spec.rb) already existed in error_helper but wasn't emphasized enough, leading to flat file generation initially. Making this MANDATORY prevents future violations.

---

### Version 1.15.0 - 2026-02-11
**Type**: MINOR (View i18n management requirement)

**Changes**:
- Added new principle: IX. Application View Internationalization (i18n) Management
- Established requirements for view locale files:
  - Create/update config/locales/app/views/[path]/[view_name].en.yml when creating/updating views
  - Mirror app/views/ directory structure in config/locales/app/views/
  - Include ALL user-facing text (titles, labels, buttons, placeholders, messages)
  - Use lazy lookup pattern: t('.key') instead of t('full.path.key')
  - Rails infers full key from view path automatically
  - Update locale file when adding/removing/changing user-facing text
  - Commit locale files alongside view changes (same PR/commit)
- Added implementation process with view locale file template
- Added example for Devise sessions new view showing all text elements
- Added usage examples demonstrating lazy lookup: t('.title'), t('.submit_button')
- Updated locale file organization structure:
  - Added config/locales/app/views/ mirroring app/views/ directory structure
  - Example paths: devise/sessions/new.en.yml, polls/index.en.yml
  - One locale file per view template
- Added maintenance workflow (modify view text → update locale → use t('.key') → commit together)
- Listed benefits: centralized view text, easy localization, DRY code, consistent wording, lazy lookup reduces verbosity, maintainability, refactoring safety, designer-friendly

**Rationale**: Devise sessions view i18n revealed need for standardized view i18n management. Hardcoded strings in views make localization difficult and create maintenance burden when copy changes. Rails i18n supports lazy lookup (t('.key')) which automatically infers full key from view path, reducing verbosity and improving maintainability. Creating config/locales/app/views/[path]/[view].en.yml per view ensures all user-facing text is translatable. Mirroring app/views/ directory structure in config/locales/app/views/ maintains clear 1:1 mapping and makes locale files easy to find. Pattern aligns with Rails i18n best practices and supports future multi-language requirements without code changes.

---

### Version 1.14.0 - 2026-02-11
**Type**: PATCH (Model i18n spec requirement)

**Changes**:
- Updated Principle VIII: Application Model i18n Management
- Added i18n spec requirement for model translations:
  - Create/update spec/models/[model]/i18n_spec.rb when creating/updating models
  - Test model name translations (singular and plural)
  - Test ALL attribute name translations (one test per attribute)
  - Tests verify Model.model_name.human and Model.human_attribute_name(:attribute)
  - Update i18n spec when adding/removing/renaming attributes
  - Commit i18n spec alongside model and locale file changes
- Added i18n spec template with example structure
- Updated implementation process to include i18n spec creation
- Updated maintenance workflow to include i18n spec updates and test runs
- Updated benefits list: added test coverage, prevent regressions
- Updated directory structure diagram to show spec/models/[model]/i18n_spec.rb

**Rationale**: User model i18n setup revealed need for testing i18n translations. Without tests, missing or incorrect translations aren't caught until runtime, potentially showing technical attribute names (e.g., "email" instead of "Email") to users. Testing Model.model_name.human and Model.human_attribute_name ensures locale files are properly configured and loaded. Following model spec organization pattern (spec/models/user/i18n_spec.rb), this creates one focused spec file per concern. Tests serve as documentation for expected attribute labels and catch regressions during locale file updates.

---

### Version 1.13.0 - 2026-02-11
**Type**: MINOR (Application model i18n management requirement)

**Changes**:
- Added new principle: VIII. Application Model Internationalization (i18n) Management
- Established requirements for model locale files:
  - Create/update config/locales/app/models/[model_name].en.yml when creating/updating models
  - Include model names (singular/plural) under activerecord.models namespace
  - Include ALL attributes under activerecord.attributes.[model_name] (database columns + virtual attributes)
  - Follow Rails i18n namespace conventions (activerecord.models, activerecord.attributes)
  - Update locale file when adding/removing/renaming attributes
  - Commit locale files alongside model changes (same PR/commit)
- Added implementation process with model locale file template
- Added example for User model showing database columns and virtual attributes
- Added usage examples: User.model_name.human, User.human_attribute_name(:email)
- Updated locale file organization structure:
  - Added config/locales/app/models/ for application model translations
  - Separated app-specific (app/) from gem-specific (gems/) locale directories
  - Maintained config/locales/en.yml for global application translations
- Added maintenance workflow (add attribute → update locale → commit together)
- Listed benefits: centralized translations, human-readable errors, consistent terminology, easy customization, multi-language ready, Rails integration, maintainability

**Rationale**: User model creation revealed need for standardized model i18n management. Rails i18n supports model/attribute name translation via activerecord.models and activerecord.attributes, but requires explicit locale files. Creating config/locales/app/models/xxx.en.yml per model ensures all attribute names are translatable, improving user-facing error messages and form labels. Separating application-specific (app/) from gem-specific (gems/) locale files improves organization and prevents mixing concerns. Pattern aligns with Rails i18n best practices (User.model_name.human, User.human_attribute_name(:email)) and supports future multi-language requirements.

---

### Version 1.12.0 - 2026-02-11
**Type**: MINOR (Gem i18n management principle)

**Changes**:
- Added new principle: VII. Gem Internationalization (i18n) Management
- Established requirements for managing gem locale files:
  - Copy locale files from gem GitHub repos to config/locales/gems/[gem_name]/
  - Directory organization: rails/, devise/, etc.
  - Use official GitHub source at tagged version matching installed gem
  - Download ALL locale files (minimum en.yml)
  - Rails core uses separate files: actionview.en.yml, activemodel.en.yml, activerecord.en.yml, activesupport.en.yml
  - Commit locale files to version control (NOT ignored)
- Added implementation process with curl examples for Rails 8.1.2 and Devise
- Added configuration requirements: recursive locale loading via config.i18n.load_path
- Added locale file organization structure showing gems/ directory hierarchy
- Documented gem upgrade process (check version, download new files, review diff, test, commit)
- Listed benefits: version control, customization, offline development, explicit visibility, consistency, review process, debugging

**Rationale**: Rails 8.1.2 i18n setup revealed that gems include locale files in their load paths, but these aren't tracked in version control or easily customizable. Copying from GitHub to config/locales/gems/ ensures explicit control over all user-facing text and supports i18n best practices with recursive locale loading. This pattern applies to Rails core components (actionview, activemodel, activerecord, activesupport) and third-party gems (Devise, Pundit, etc.). Directory organization keeps gem locale files separate from application-specific translations, improving maintainability and reducing merge conflicts during gem upgrades.

---

### Version 1.11.0 - 2026-02-10
**Type**: PATCH (Helper spec organization pattern)

**Changes**:
- Updated Principle II (Test-Driven Development) > Test Organization
- Added Helper Spec Organization Pattern section with requirements:
  - Helper specs organized by helper module in subdirectories (spec/helpers/[helper_name]/)
  - One spec file per public method ([method_name]_spec.rb)
  - Each file tests ONE method only (focused, single responsibility)
- Updated spec/ directory structure example to show helper organization:
  - Added spec/helpers/error_helper/ example with 3 method-specific spec files
  - Added spec/helpers/application_helper/ example
- Documented benefits: easy test location, faster test runs, 1:1 file-method mapping, simplified PRs, better git history
- Provided code example showing spec file structure for helper methods

**Rationale**: ErrorHelper refactoring revealed need for standardized helper spec organization. All helper methods were tested in single file (error_helper_spec.rb with 13 examples), making it harder to locate and run tests for specific methods. Splitting into separate files (field_error_message_spec.rb, field_icon_color_spec.rb, field_border_classes_spec.rb) improved maintainability and follows single responsibility principle at file level. Pattern aligns with Rails convention of one concern per file and mirrors spec/models/ organization (one model = one spec file). This prevents helper spec files from becoming unwieldy as helper modules grow.

---

### Version 1.10.0 - 2026-02-10
**Type**: MINOR (RSpec testing framework standardization)

**Changes**:
- Expanded Principle II (Test-Driven Development) with comprehensive RSpec requirements
- Added Testing Framework section specifying RSpec as mandatory
- Added Test Types and Coverage Requirements (model 95%, request 90%, system critical paths)
- Added Automatic Spec Generation requirements via Rails generators
- Added "When Creating/Updating Code" workflow mandating specs alongside code
- Added Test Data Management section (FactoryBot, Faker, traits)
- Added Test Helpers and Support section (Shoulda Matchers, Database Cleaner, Devise helpers)
- Added Running Tests commands and Test Organization structure
- Updated Technology Stack > Testing: Added Shoulda Matchers, Database Cleaner, Selenium WebDriver
- Made "Every commit MUST include specs" explicit requirement

**Rationale**: RSpec provides superior BDD-style testing with self-documenting "describe/context/it" structure. FactoryBot reduces test data boilerplate compared to fixtures. Shoulda Matchers simplify Rails validation tests. Automatic spec generation via Rails generators ensures tests are written alongside code, not as afterthought. This codifies existing testing infrastructure and prevents regression to Minitest or manual test creation.

---

### Version 1.
## Version History

### Version 1.9.0 - 2026-02-10
**Type**: MINOR (Error handling and validation UX principle)

**Changes**:
- Added new principle: VI. User-Centric Error Handling & Validation UX
- Established validation error display requirements:
  - Inline field errors directly below invalid inputs
  - Visual indicators: red borders (`border-red-500`), red icons (`text-red-400`)
  - Error text using Tailwind v4 compatible colors (`text-red-700`)
  - Consistent focus states (red border maintained, no black ring fallback)
- Defined Tailwind Notifications pattern for form errors:
  - Fixed top-right position (`fixed top-4 right-4 z-50`)
  - Error summary with count and resource name
  - Dismissible close button with accessible labels
  - Professional styling with ring shadow
- Added implementation standards with ERB code examples
- Specified Tailwind v4 color constraints (avoid `text-red-600`, use available variants only)
- Required progressive enhancement (errors work without JavaScript)
- Mandated consistency across all forms (authentication, resource CRUD)

**Rationale**: User signup form improvements revealed need for standardized error handling pattern. Inconsistent error feedback creates poor UX and increases user frustration. This principle codifies: (1) top-right notification for global context, (2) inline field errors for actionable guidance, (3) visual indicators for immediate recognition. Pattern follows Tailwind UI best practices and modern web application standards. Tailwind v4's on-demand class generation requires explicit color utility verification to prevent styling bugs (e.g., `text-red-600` not generated, renders as black).

---

### Version 1.8.0 - 2026-02-10
**Type**: MINOR (Commit message format - spec and task number prefixes)

**Changes**:
- Updated Development Standards > Workflow: Added mandatory commit message prefix format
- Commit messages for spec-related work MUST include `[specs#xxx][tasks#yyy]` prefix
- Added format specification: `[specs#xxx][tasks#yyy] type: description`
  - xxx = spec number (zero-padded, e.g., 001)
  - yyy = task number (zero-padded, e.g., 054)
  - type = conventional commit type (feat, fix, refactor, test, docs)
- Example: `[specs#001][tasks#054] test: add User model validation tests`
- Exception documented for infrastructure/non-spec commits

**Rationale**: Standardized commit prefixes enable traceability between commits and specification tasks. The format creates explicit links in git history, facilitating automated verification of spec completion, improving audit trails for feature implementation, and enabling tooling to track task-to-commit mappings. This enhances existing conventional commit format with spec/task context without replacing it.

---

### Version 1.7.0 - 2026-02-10
**Type**: MINOR (UI standards - Tailwind CSS official patterns requirement)

**Changes**:
- Updated Technology Stack > Frontend: Added requirement to use official Tailwind CSS patterns from https://tailwindcss.com/
- Added "UI Standards" subsection to Development Standards with specific Tailwind CSS usage requirements:
  - Mandates using official tailwindcss.com patterns for all screens
  - Prohibits custom gradients, animations, or non-standard utility classes
  - Requires semantic Tailwind utilities (`ring-*` for focus, `leading-*` for spacing)
  - Enforces mobile-first responsive design with standard breakpoints
  - Specifies form validation and authentication pages must follow official examples

**Rationale**: Recent UI refactoring demonstrated benefits of migrating from custom designs to official Tailwind CSS patterns. Official patterns are community-tested for accessibility, responsive design, and cross-browser compatibility. This constitutional requirement prevents future custom implementations that diverge from Tailwind's design system, ensuring consistency across all screens. Forms, authentication pages, and component layouts leveraging tailwindcss.com examples reduce maintenance overhead and inherit best practices from the Tailwind community.

---

### Version 1.6.0 - 2026-02-10
**Type**: PATCH (Documentation clarity - production environment)

**Changes**:
- Updated .env.example to add "⚠️ PRODUCTION ONLY" warning for DATABASE_URL
- Added comprehensive "Production Environment (Render.com Only)" section to README.md
- Documented DATABASE_URL auto-provisioning and override behavior
- Added local vs production database configuration comparison
- Updated production section in Environment Configuration to reference detailed production docs
- Clarified that DATABASE_URL should never be set in local .env files

**Rationale**: Previous documentation mentioned DATABASE_URL but lacked critical context about production-only usage. Developers could mistakenly set DATABASE_URL in local .env files, which overrides individual database variables (POLL_VOTING_DATABASE_HOST, PORT, USERNAME, PASSWORD) and breaks local development. Explicit warnings and detailed production environment documentation prevent misconfiguration and improve new developer onboarding experience.

---

### Version 1.5.0 - 2026-02-10
**Type**: PATCH (Documentation completeness)

**Changes**:
- Updated README.md to document POLL_VOTING_DATABASE_HOST and POLL_VOTING_DATABASE_PORT
- Added database host/port variables to Quick Start section
- Added database host/port variables to Environment Configuration section
- No code changes (variables already existed in .env.example and database.yml)

**Rationale**: Constitutional requirement mandates README.md accuracy for all environment variables affecting local development. These variables were already implemented but missing from documentation, creating potential confusion for new developers during setup.

---

### Version 1.4.0 - 2026-02-10
**Type**: MINOR (Version history tracking)

**Changes**:
- Added Version History section to track all constitutional amendments
- Updated Amendment Process to require history entry for each change
- Replaced single version line with reference to history section

**Rationale**: Provides audit trail of governance evolution. Transparency and historical context support better decision-making for future amendments.

---

### Version 1.3.0 - 2026-02-10
**Type**: MINOR (README.md synchronization requirement)

**Changes**:
- Added README.md synchronization mandate to Documentation Requirements
- Specified README update triggers in Environment Configuration:
  - New environment variables affecting local development
  - Third-party service integrations
  - Configuration step changes
  - Prerequisite changes
- Made README Quick Start accuracy a NON-NEGOTIABLE requirement

**Rationale**: New developers rely on README.md for local setup. Outdated setup instructions break developer onboarding experience. Mandatory README updates ensure documentation stays synchronized with configuration changes.

---

### Version 1.2.0 - 2026-02-10
**Type**: MINOR (Environment configuration documentation)

**Changes**:
- Added Environment Configuration section to Development Standards
- Added .env.example maintenance requirement to Documentation Requirements
- Specified required production variables (DATABASE_URL, REDIS_URL, RAILS_MASTER_KEY)
- Defined security variables (RAILS_FORCE_SSL, RACK_ATTACK configuration)

**Rationale**: Explicit environment variable documentation ensures consistent configuration across development, staging, and production. .env.example serves as canonical reference for required and optional environment variables.

---

### Version 1.1.0 - 2026-02-10
**Type**: MINOR (Deployment target change)

**Changes**:
- Updated Technology Stack > Deployment: Kamal 2.0 → Render.com
- Updated Development Standards > Workflow: Added Render.com deployment notes
- Changed from Docker/Kamal to Render.com native buildpacks
- Added GitHub integration for automatic deployments
- Updated workflow: Database migrations tested in Render preview environments

**Rationale**: Render.com provides managed PostgreSQL, Redis, and automatic deployments from Git, reducing infrastructure complexity and maintenance overhead. No Docker containerization needed - Render uses native buildpacks.

---

### Version 1.0.0 - 2026-02-10
**Type**: MAJOR (Initial ratification)

**Changes**:
- Initial constitution ratified
- Established 5 core principles:
  - I. Rails-First Architecture
  - II. Test-Driven Development (NON-NEGOTIABLE)
  - III. SSR Performance & User Experience
  - IV. Security by Default
  - V. Simplicity & Maintainability
- Defined Technology Stack (Ruby 4, Rails 8, PostgreSQL, Redis, Hotwire, Tailwind)
- Established Development Standards (code quality gates, workflow, documentation)
- Created Governance framework (amendment process, compliance, runtime guidance)

**Rationale**: Foundation document establishing project governance, technical principles, and development standards for Rails Poll Voting application.
