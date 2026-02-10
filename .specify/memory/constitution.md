<!--
SYNC IMPACT REPORT - Constitution Update
========================================
Version Change: 1.10.0 → 1.11.0
Type: PATCH (Helper spec organization pattern)

Modified Sections:
  - II. Test-Driven Development > Test Organization - Added helper spec organization pattern

Added Requirements:
  - Helper specs MUST be organized by helper module in subdirectories
  - One spec file per public method (e.g., spec/helpers/error_helper/field_error_message_spec.rb)
  - Each spec file tests ONE method only (focused, single responsibility)
  - Updated spec/ directory structure example to show helper organization

Benefits Documented:
  - Easy to locate tests for specific helper method
  - Faster test runs when working on single method (run one file)
  - Clear 1:1 mapping between file and method
  - Simplified pull requests (method changes affect single spec file)
  - Better git history (method-specific commits touch only relevant spec file)

Rationale:
  ErrorHelper refactoring revealed need for standardized helper spec organization. Previously,
  all helper methods tested in single file (error_helper_spec.rb with 13 examples). Splitting
  into separate files (field_error_message_spec.rb, field_icon_color_spec.rb,
  field_border_classes_spec.rb) improved maintainability and follows single responsibility
  principle at file level. Pattern mirrors Rails convention of one concern per file and aligns
  with spec/models/ organization (one model = one spec file). This standard prevents helper
  spec files from becoming unwieldy as helper modules grow.

Template Consistency Status:
  ✅ plan-template.md - No changes required (spec organization not in planning phase)
  ✅ spec-template.md - No changes required (acceptance criteria unchanged)
  ✅ tasks-template.md - No changes required (task patterns unchanged)
  ✅ README.md - Already documents RSpec testing structure

Follow-up TODOs:
  - None (pattern already implemented in spec/helpers/error_helper/)

Previous Update (v1.10.0):
  Added RSpec testing framework standardization with comprehensive requirements,
  automatic spec generation, FactoryBot, Shoulda Matchers, and coverage requirements.
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

**Current Version**: 1.11.0 | **Ratified**: 2026-02-10 | **Last Amended**: 2026-02-10

---

## Version History

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
