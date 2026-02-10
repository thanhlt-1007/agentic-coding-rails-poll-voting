<!--
SYNC IMPACT REPORT - Constitution Update
========================================
Version Change: 1.8.0 → 1.9.0
Type: MINOR (Error handling and validation UX principle)

Modified Principles: None
Added Principles:
  - VI. User-Centric Error Handling & Validation UX

Added Requirements:
  - Validation error display requirements (inline field errors, visual indicators, notifications)
  - Tailwind Notifications pattern for form errors (fixed top-right position)
  - Inline field error messages directly below invalid inputs
  - Red border and icon highlighting for invalid fields
  - Error text color constraints for Tailwind v4 compatibility
  - Consistent error patterns across all forms
  - Progressive enhancement requirement (errors work without JavaScript)
  - Tailwind v4 color utility verification requirement

Rationale:
  Recent user signup form improvements demonstrated need for standardized error handling
  across all application forms. Inconsistent error feedback creates poor UX and increases
  user frustration. This principle codifies the pattern: (1) top-right notification for
  global error summary, (2) inline field errors for actionable feedback, (3) visual
  indicators (red borders/icons) for immediate recognition. The pattern balances visibility
  with usability, following Tailwind UI best practices. Tailwind v4's on-demand class
  generation requires explicit color utility verification to prevent black-rendering bugs
  (e.g., text-red-600 not generated, falls back to currentColor/black).

Template Consistency Status:
  ✅ plan-template.md - No changes required (form error handling not in planning phase)
  ✅ spec-template.md - Will add validation UX requirements to UI section template
  ✅ tasks-template.md - Will add error handling tasks to form implementation checklist
  ⚠️  README.md - Consider adding UX standards section referencing constitution
  ✅ .env.example - No changes required

Follow-up TODOs:
  - TODO(spec-template): Add "Validation & Error Handling" subsection to UI Requirements
  - TODO(tasks-template): Add "T0XX: Implement form validation with error feedback" task pattern
  - TODO(README): Consider adding "UX Standards" section linking to constitution principle VI
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

**Test coverage requirements**:
- System tests for critical user journeys (voting flows, poll creation)
- Request tests for all controller actions
- Model tests for validations, associations, business logic
- Minimum 90% coverage on models and services

**Rationale**: Tests are executable specifications. Writing them first ensures we build what's needed, not what's easy. Early validation prevents costly rewrites.

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
- RSpec (system, request, model specs)
- FactoryBot for test data
- Faker for realistic fake data
- Capybara for system tests
- SimpleCov for coverage tracking

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

**Current Version**: 1.9.0 | **Ratified**: 2026-02-10 | **Last Amended**: 2026-02-10

---

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
