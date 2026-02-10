<!--
SYNC IMPACT REPORT - Constitution Update
========================================
Version Change: 1.6.0 → 1.7.0
Type: MINOR (Bilingual specification workflow)

Modified Principles: None
Modified Sections: Development Standards > Documentation Requirements (bilingual spec requirement)

Rationale: 
  Bilingual documentation (English + Vietnamese) improves accessibility for Vietnamese-speaking
  team members and stakeholders while maintaining English as the international standard.
  English specification (spec.en.md) serves as the source of truth, then translated to
  Vietnamese (spec.vi.md) to ensure consistency. This workflow ensures all stakeholders can
  review and understand feature specifications in their preferred language.

Template Consistency Status:
  ⚠️  spec-template.md - Needs update to generate both spec.en.md and spec.vi.md
  ⚠️  speckit.specify.prompt.md - Needs update to enforce bilingual workflow
  ✅ plan-template.md - No changes required
  ✅ tasks-template.md - No changes required
  ✅ README.md - May need bilingual version (future consideration)
  ✅ .env.example - No changes required

Follow-up TODOs:
  - Update spec-template.md to include bilingual instructions
  - Update speckit.specify command to generate both spec.en.md and spec.vi.md
  - Translate existing spec.md to spec.en.md and spec.vi.md
  - Consider bilingual README.md for future releases
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

## Technology Stack

**Core**:
- Ruby 4.0+ (latest stable)
- Rails 8.0+ (leveraging Solid Queue, Solid Cache, Solid Cable)
- PostgreSQL 15+ (primary database)
- Redis 7+ (caching, session store)

**Frontend**:
- Hotwire (Turbo + Stimulus) for SPA-like interactions
- Tailwind CSS 4+ for styling
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
- Commits: conventional commits format (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`)
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
- Feature specifications MUST be bilingual (NON-NEGOTIABLE):
  - Generate spec.en.md FIRST in English (source of truth)
  - Translate spec.en.md to spec.vi.md in Vietnamese
  - Both files MUST be kept in sync when changes occur
  - English version takes precedence in case of translation discrepancies
  - Workflow: English specification → Vietnamese translation → validate consistency
- README updated for new user-facing features
- Inline comments for non-obvious business logic
- API documentation via RDoc for public methods
- Database schema maintained (schema.rb automatically tracked)
- .env.example updated when new environment variables introduced

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

**Current Version**: 1.7.0 | **Ratified**: 2026-02-10 | **Last Amended**: 2026-02-10

---

## Version History

### Version 1.7.0 - 2026-02-10
**Type**: MINOR (Bilingual specification workflow)

**Changes**:
- Added bilingual specification requirement to Documentation Requirements section
- Feature specifications MUST be created in both English (spec.en.md) and Vietnamese (spec.vi.md)
- English version (spec.en.md) is the source of truth, generated first
- Vietnamese version (spec.vi.md) is translated from English
- Both files must be kept in sync when changes occur
- English takes precedence in case of translation discrepancies

**Rationale**: Bilingual documentation improves accessibility for Vietnamese-speaking team members and stakeholders while maintaining English as the international standard. This ensures all stakeholders can review and understand feature specifications in their preferred language. English-first workflow prevents translation drift and establishes clear source of truth. This supports inclusive collaboration while maintaining professional documentation standards required for international deployment.

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
