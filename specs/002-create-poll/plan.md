# Implementation Plan: Poll Creation

**Branch**: `002-create-poll` | **Date**: February 11, 2026 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-create-poll/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement poll creation functionality allowing authenticated users to create polls with one question and exactly four answer options. Each poll supports single-choice voting (radio button behavior) and optionally includes a deadline for automatic closure. Users must be authenticated before accessing the poll creation form, which validates all inputs (required question, four unique answers, future deadline if provided) and provides clear error feedback. Upon successful creation, polls are associated with their creator and stored with timestamps.

## Technical Context

**Language/Version**: Ruby 3.3 / Rails 8.1.2  
**Primary Dependencies**: Devise (authentication), RSpec (testing), PostgreSQL (storage), Tailwind CSS (styling)  
**Storage**: PostgreSQL (primary database with multi-database support for Solid Cache/Queue/Cable)  
**Testing**: RSpec with FactoryBot, Shoulda Matchers, Capybara (system specs)  
**Target Platform**: Web application (server-rendered HTML with Turbo/Hotwire)  
**Project Type**: Web application (Rails MVC monolith)  
**Performance Goals**: <200ms page load for poll creation form, <500ms poll creation processing  
**Constraints**: All code must pass RuboCop with zero offenses, 90%+ test coverage required  
**Scale/Scope**: Small feature (2 models, 1 controller, 3 views, authentication integration)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Principle I - Rails-First Architecture**: ✅ PASS  
- Using Rails generators for models, controllers, migrations
- Following MVC pattern: Poll/Answer models, PollsController, form views
- Leveraging Active Record for associations and validations
- Using Turbo/Hotwire for form submissions (no custom JavaScript needed)

**Principle II - Test-Driven Development**: ✅ PASS  
- All code will be test-driven (RSpec specs before implementation)
- Model specs for Poll and Answer validations/associations
- Request specs for PollsController actions (organized by action pattern)
- System specs for end-to-end poll creation flow
- Minimum 90% test coverage requirement

**Principle III - I18n for User-Facing Text**: ✅ PASS  
- All flash messages in config/locales/app/controllers/polls/[action].en.yml
- Form labels in config/locales/app/views/polls/new.en.yml
- Error messages using Rails i18n (activerecord.errors.models.poll)
- Using lazy lookup pattern t('.key') in controllers and views

**Principle IV - Helpers for Reusable Logic**: ✅ PASS  
- Can leverage existing ErrorHelper for form error display
- May create PollsHelper for poll-specific view logic if needed
- All helper methods must have corresponding specs in spec/helpers/

**Principle IX - View/Partial I18n Mapping**: ✅ PASS  
- Poll creation form view will have corresponding i18n file
- config/locales/app/views/polls/new.en.yml for form labels and text
- 1:1 mapping between views and i18n files

**Principle X - Controller I18n Management**: ✅ PASS  
- Create config/locales/app/controllers/polls/create.en.yml for flash messages
- Create config/locales/app/controllers/polls/new.en.yml if needed
- Organize by action (one file per action with user-facing messages)
- Use lazy lookup: t('.success'), t('.error')

**Principle XII - RuboCop Code Style Compliance**: ✅ PASS  
- All code will pass `bin/rubocop` with zero offenses before committing
- Follow rubocop-rails-omakase conventions (double quotes, array spacing)
- Pre-commit workflow: tests → rubocop → fix → commit

**Additional Checks**:
- **Authentication**: Uses existing Devise setup from specs/001-user-signup (✅ PASS)
- **Database**: PostgreSQL multi-database configuration already in place (✅ PASS)
- **Request Spec Organization**: Will follow organized pattern (spec/requests/polls/[http_method]_[action]_spec.rb) (✅ PASS)

**Constitution Violations**: NONE  
**Justification Required**: N/A

## Project Structure

### Documentation (this feature)

```text
specs/002-create-poll/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (Rails nested attributes, validation patterns)
├── data-model.md        # Phase 1 output (Poll/Answer schema, associations)
├── quickstart.md        # Phase 1 output (dev setup, running tests)
├── contracts/           # Phase 1 output (not applicable for Rails forms)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
app/
├── models/
│   ├── poll.rb                          # Poll model (question, deadline, user association)
│   └── answer.rb                        # Answer model (text, position, poll association)
├── controllers/
│   └── polls_controller.rb              # Polls controller (new, create actions)
├── views/
│   └── polls/
│       ├── new.html.erb                 # Poll creation form
│       ├── show.html.erb                # Poll confirmation/details page
│       └── _form.html.erb               # Poll form partial (if needed)
├── helpers/
│   └── polls_helper.rb                  # Poll-specific view helpers (if needed)
└── javascript/
    └── controllers/
        └── (leverage existing Stimulus if needed)

config/
├── routes.rb                            # Add polls resources
└── locales/
    └── app/
        ├── controllers/
        │   └── polls/
        │       ├── new.en.yml           # Flash messages for new action
        │       └── create.en.yml        # Flash messages for create action
        └── views/
            └── polls/
                └── new.en.yml           # Form labels and text

db/
├── migrate/
│   ├── [timestamp]_create_polls.rb      # Polls table migration
│   └── [timestamp]_create_answers.rb    # Answers table migration
└── schema.rb                            # Updated schema

spec/
├── models/
│   ├── poll_spec.rb                     # Poll model specs
│   └── answer_spec.rb                   # Answer model specs
├── requests/
│   └── polls/
│       ├── get_new_spec.rb              # GET /polls/new request specs
│       └── post_create_spec.rb          # POST /polls request specs
├── system/
│   └── poll_creation_spec.rb            # End-to-end poll creation flow
└── factories/
    ├── polls.rb                         # Poll factory
    └── answers.rb                       # Answer factory
```

**Structure Decision**: This is a standard Rails MVC web application following the existing project structure. Request specs use the organized pattern (one file per action) as established in specs/001-user-signup. I18n files follow the controller/view organization pattern from the constitution. All code follows Rails conventions with RuboCop compliance.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**No violations detected** - Constitution check passed all gates.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
