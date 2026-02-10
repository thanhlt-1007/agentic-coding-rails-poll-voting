---
description: "Task list for poll creation feature implementation"
---

# Tasks: Poll Creation

**Input**: Design documents from `/specs/002-create-poll/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Tests**: This project uses TDD (Constitution Principle II) - all tasks include test creation FIRST

**Organization**: Tasks grouped by user story for independent implementation and testing

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story (US1, US2, US3, US4, US5, US6)
- Include exact file paths in descriptions

## Path Conventions

Rails MVC structure:
- Models: `app/models/`
- Controllers: `app/controllers/`
- Views: `app/views/polls/`
- Specs: `spec/models/`, `spec/requests/polls/`, `spec/system/`
- I18n: `config/locales/app/controllers/polls/`, `config/locales/app/views/polls/`
- Factories: `spec/factories/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and database setup

- [X] T001 Create database migrations for polls and answers tables per data-model.md
- [X] T002 Run migrations and verify schema in db/schema.rb
- [X] T003 [P] Create FactoryBot factory for Poll in spec/factories/polls.rb
- [X] T004 [P] Create FactoryBot factory for Answer in spec/factories/answers.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Poll and Answer models with validations - MUST complete before controller/view work

**⚠️ CRITICAL**: No controller or view work can begin until models are complete and tested

### Poll Model Foundation

- [X] T005 Write Poll model spec in spec/models/poll_spec.rb (associations, validations, nested attributes)
- [X] T006 Run Poll model spec - verify it FAILS (Red phase of TDD)
- [X] T007 Implement Poll model in app/models/poll.rb (belongs_to :user, has_many :answers, accepts_nested_attributes_for :answers)
- [X] T008 Add Poll validations in app/models/poll.rb (question presence/length, answers length: 4)
- [X] T009 Add custom validation in app/models/poll.rb (answers_must_be_unique method)
- [X] T010 Add custom validation in app/models/poll.rb (deadline_must_be_in_future method)
- [X] T011 Add Poll scopes in app/models/poll.rb (recent, active, expired)
- [X] T012 Run Poll model spec - verify it PASSES (Green phase of TDD)
- [X] T013 Run RuboCop on app/models/poll.rb - fix all offenses

### Answer Model Foundation

- [X] T014 Write Answer model spec in spec/models/answer_spec.rb (associations, validations, uniqueness)
- [X] T015 Run Answer model spec - verify it FAILS (Red phase of TDD)
- [X] T016 Implement Answer model in app/models/answer.rb (belongs_to :poll)
- [X] T017 Add Answer validations in app/models/answer.rb (text presence/length, position presence/numericality, position uniqueness scoped to poll_id)
- [X] T018 Add Answer scope in app/models/answer.rb (ordered by position)
- [X] T019 Add Answer to_s method in app/models/answer.rb
- [X] T020 Run Answer model spec - verify it PASSES (Green phase of TDD)
- [X] T021 Run RuboCop on app/models/answer.rb - fix all offenses

**Checkpoint**: Foundation ready - Poll and Answer models fully tested with 100% spec coverage

---

## Phase 3: User Story 1 - Create New Poll with Question and Answers (Priority: P1) 🎯 MVP

**Goal**: Authenticated users can create polls with 1 question and 4 answer options via form submission

**Independent Test**: Login → navigate to /polls/new → fill question and 4 answers → submit → poll created in database

### Request Specs for User Story 1 (TDD - Write Tests FIRST)

- [X] T022 [P] [US1] Write GET /polls/new request spec in spec/requests/polls/get_new_spec.rb (authenticated user sees form)
- [X] T023 [P] [US1] Write POST /polls request spec in spec/requests/polls/post_create_spec.rb (successful poll creation with nested answers)
- [X] T024 [US1] Run request specs - verify they FAIL (Red phase of TDD)

### Controller Implementation for User Story 1

- [X] T025 [US1] Generate PollsController with new, create, show actions (rails generate controller Polls new create show)
- [X] T026 [US1] Add before_action :authenticate_user! in app/controllers/polls_controller.rb
- [X] T027 [US1] Implement new action in app/controllers/polls_controller.rb (@poll = Poll.new; 4.times { @poll.answers.build })
- [X] T028 [US1] Implement create action in app/controllers/polls_controller.rb (current_user.polls.build, save with redirect or re-render)
- [X] T029 [US1] Implement show action in app/controllers/polls_controller.rb (Poll.find)
- [X] T030 [US1] Add poll_params private method in app/controllers/polls_controller.rb (permit :question, :deadline, answers_attributes: [:text, :position])
- [X] T031 [US1] Add polls resources route in config/routes.rb (resources :polls, only: [:new, :create, :show])
- [X] T032 [US1] Run request specs - verify they PASS (Green phase of TDD)
- [X] T033 [US1] Run RuboCop on app/controllers/polls_controller.rb - fix all offenses

### Views for User Story 1

- [X] T034 [US1] Create poll creation form in app/views/polls/new.html.erb (form_with model: @poll, text_area :question, datetime_local_field :deadline)
- [X] T035 [US1] Add fields_for :answers in app/views/polls/new.html.erb (4 answer text_field inputs with hidden position field)
- [X] T036 [US1] Add error display in app/views/polls/new.html.erb (@poll.errors.full_messages with Tailwind styling)
- [X] T037 [US1] Create poll confirmation view in app/views/polls/show.html.erb (display question, deadline, answers.ordered)
- [X] T038 [US1] Run system spec manually (login → create poll → verify success) - verify form renders and submission works

### I18n for User Story 1

- [X] T039 [P] [US1] Create controller i18n file config/locales/app/controllers/polls/create.en.yml (success, error messages)
- [X] T040 [P] [US1] Create view i18n file config/locales/app/views/polls/new.en.yml (title, labels, placeholders, help text)
- [X] T041 [US1] Update new.html.erb to use t('.title'), t('.question_label'), etc. with lazy lookup
- [X] T042 [US1] Update create action to use t('.success') and t('.error') for flash messages
- [X] T043 [US1] Verify i18n keys load correctly (restart server, check for missing translation errors)

**Checkpoint**: User Story 1 complete - authenticated users can create polls via form, all tests passing

---

## Phase 4: User Story 2 - Authentication Requirement for Poll Creation (Priority: P1)

**Goal**: Unauthenticated users are redirected to login when accessing poll creation

**Independent Test**: Logout → navigate to /polls/new → redirected to login page

### Request Specs for User Story 2 (TDD - Write Tests FIRST)

- [X] T044 [US2] Add unauthenticated context to spec/requests/polls/get_new_spec.rb (test redirect to new_user_session_path)
- [X] T045 [US2] Add unauthenticated context to spec/requests/polls/post_create_spec.rb (test redirect to new_user_session_path)
- [X] T046 [US2] Run request specs - verify unauthenticated tests PASS (before_action :authenticate_user! already in place from T026)

### System Spec for User Story 2

- [X] T047 [US2] Create system spec in spec/system/poll_creation_authentication_spec.rb (test unauthenticated redirect, login redirect back)
- [X] T048 [US2] Run system spec - verify it PASSES
- [X] T049 [US2] Run RuboCop on spec/system/poll_creation_authentication_spec.rb - fix all offenses

**Checkpoint**: User Story 2 complete - authentication enforced, unauthenticated users cannot create polls

---

## Phase 5: User Story 3 - Poll Creation Form Validation (Priority: P1)

**Goal**: Users receive clear error messages for invalid poll data (blank question, missing answers, duplicates)

**Independent Test**: Login → submit poll with blank question → see error "Question can't be blank"

### Request Specs for User Story 3 (TDD - Write Tests FIRST)

- [X] T050 [US3] Add validation failure contexts to spec/requests/polls/post_create_spec.rb (blank question, fewer than 4 answers, blank answers, duplicate answers)
- [X] T051 [US3] Test that validation failures return status :unprocessable_entity in spec/requests/polls/post_create_spec.rb
- [X] T052 [US3] Test that validation failures render :new template in spec/requests/polls/post_create_spec.rb
- [X] T053 [US3] Test that validation failures set flash.now[:alert] in spec/requests/polls/post_create_spec.rb
- [X] T054 [US3] Run request specs - verify validation tests PASS (validations already in Poll model from T008-T010)

### View Error Display for User Story 3

- [X] T055 [US3] Verify error messages display in app/views/polls/new.html.erb (error partial already added in T036)
- [X] T056 [US3] Test error display with manual form submission (blank fields, duplicates) - verify Tailwind error styling renders

### System Spec for User Story 3

- [X] T057 [US3] Create validation system spec in spec/system/poll_creation_validation_spec.rb (test blank question error, duplicate answers error)
- [X] T058 [US3] Run validation system spec - verify it PASSES
- [X] T059 [US3] Run RuboCop on spec/system/poll_creation_validation_spec.rb - fix all offenses

**Checkpoint**: User Story 3 complete - validation errors display clearly, poll creation prevented on invalid input

---

## Phase 6: User Story 4 - Poll Creation Form Display (Priority: P2)

**Goal**: Authenticated users can easily access and view poll creation form with clear labels

**Independent Test**: Login → navigate to /polls/new → verify form has question field, 4 answer fields, deadline field, submit button

### Request Specs for User Story 4 (TDD - Write Tests FIRST)

- [X] T060 [US4] Add form content expectations to spec/requests/polls/get_new_spec.rb (verify response body includes form elements)
- [X] T061 [US4] Run request spec - verify form content tests PASS (form already created in T034-T035)

### View Enhancements for User Story 4

- [X] T062 [US4] Review app/views/polls/new.html.erb - ensure all fields have clear labels from i18n
- [X] T063 [US4] Verify Tailwind styling for form (spacing, borders, focus states)
- [X] T064 [US4] Add submit button styling in app/views/polls/new.html.erb (Tailwind primary button classes)
- [X] T065 [US4] Manual test: login → navigate to /polls/new → verify form is visually clear and accessible

### System Spec for User Story 4

- [X] T066 [US4] Create form display system spec in spec/system/poll_creation_form_display_spec.rb (test all form fields present, labels visible)
- [X] T067 [US4] Run form display system spec - verify it PASSES
- [X] T068 [US4] Run RuboCop on spec/system/poll_creation_form_display_spec.rb - fix all offenses

**Checkpoint**: User Story 4 complete - poll creation form is clear, accessible, and properly labeled

---

## Phase 7: User Story 5 - Single Answer Selection Constraint (Priority: P2)

**Goal**: Polls are configured as single-choice selection type (radio button behavior for future voting)

**Independent Test**: Create poll → inspect Poll record → verify selection_type or similar attribute indicates single-choice

**Note**: This is a data model constraint, not UI implementation. Voting UI is out of scope per spec.md.

### Model Specs for User Story 5 (TDD - Write Tests FIRST)

- [X] T069 [US5] Add test to spec/models/poll_spec.rb (verify poll has single-choice selection type - could be default value or explicit field)
- [X] T070 [US5] Run Poll model spec - verify single-choice test FAILS or PASSES depending on implementation approach

### Model Implementation for User Story 5

- [X] T071 [US5] Decide implementation: add `selection_type` enum field OR document single-choice as default behavior in Poll model comments
- [X] T072 [US5] If adding field: create migration for selection_type with default 'single_choice'
- [X] T073 [US5] If adding field: run migration and verify in db/schema.rb
- [X] T074 [US5] If adding field: add enum to Poll model in app/models/poll.rb (enum selection_type: { single_choice: 0 })
- [X] T075 [US5] If documenting: add comment in app/models/poll.rb explaining single-choice constraint
- [X] T076 [US5] Run Poll model spec - verify single-choice test PASSES
- [X] T077 [US5] Run RuboCop on app/models/poll.rb - fix all offenses

**Checkpoint**: User Story 5 complete - polls are explicitly single-choice selection type

---

## Phase 8: User Story 6 - Poll Deadline (Priority: P1)

**Goal**: Users can optionally set a deadline for polls (must be in future if provided)

**Independent Test**: Create poll with future deadline → verify deadline stored; try past deadline → see error "Deadline must be in the future"

**Note**: Deadline field already included in Poll model (T007-T010) and form (T034). This phase adds comprehensive testing.

### Request Specs for User Story 6 (TDD - already mostly covered, add edge cases)

- [X] T078 [US6] Add deadline test contexts to spec/requests/polls/post_create_spec.rb (future deadline succeeds, no deadline succeeds, past deadline fails)
- [X] T079 [US6] Test deadline validation error message in spec/requests/polls/post_create_spec.rb
- [X] T080 [US6] Run request specs - verify deadline tests PASS (deadline validation already in Poll model from T010)

### View Verification for User Story 6

- [X] T081 [US6] Verify datetime_local_field for deadline in app/views/polls/new.html.erb (already added in T034)
- [X] T082 [US6] Verify deadline displays in app/views/polls/show.html.erb (already added in T037)
- [X] T083 [US6] Verify deadline i18n labels in config/locales/app/views/polls/new.en.yml (already added in T040)

### System Spec for User Story 6

- [X] T084 [US6] Create deadline system spec in spec/system/poll_creation_deadline_spec.rb (test creating poll with future deadline, test validation error for past deadline)
- [X] T085 [US6] Run deadline system spec - verify it PASSES
- [X] T086 [US6] Run RuboCop on spec/system/poll_creation_deadline_spec.rb - fix all offenses

**Checkpoint**: User Story 6 complete - deadline feature fully tested, optional deadline with future validation working

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final quality checks and documentation

- [X] T087 Run full test suite (bundle exec rspec) - verify all 100+ tests pass
- [X] T088 Check test coverage - verify 90%+ coverage for Poll, Answer, PollsController
- [X] T089 Run RuboCop on all feature files (bin/rubocop app/models/poll.rb app/models/answer.rb app/controllers/polls_controller.rb app/views/polls/) - fix all offenses
- [X] T090 [P] Update README.md with poll creation feature usage instructions
- [X] T091 [P] Verify quickstart.md instructions work (follow dev setup steps, verify they're accurate)
- [X] T092 Manual smoke test: sign up → login → create poll with all fields → verify success → check database record
- [X] T093 Manual smoke test: create poll with validation errors → verify error messages display correctly
- [X] T094 Manual smoke test: attempt to access /polls/new while logged out → verify redirect to login
- [X] T095 Run db:migrate in development and test environments - verify no migration issues
- [X] T096 Final RuboCop check on entire project (bin/rubocop) - verify 0 offenses

**Checkpoint**: Feature complete and production-ready - all tests passing, RuboCop clean, manual testing passed

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all controller/view work
- **User Story 1 (Phase 3)**: Depends on Foundational - implements core poll creation
- **User Story 2 (Phase 4)**: Depends on US1 controller (T026 before_action) - tests authentication
- **User Story 3 (Phase 5)**: Depends on US1 models/controller (T008-T010 validations) - tests validation errors
- **User Story 4 (Phase 6)**: Depends on US1 views (T034-T037 form) - tests form display
- **User Story 5 (Phase 7)**: Depends on Foundational Poll model - adds selection type
- **User Story 6 (Phase 8)**: Depends on US1 models/views (T010 validation, T034/T037 deadline fields) - tests deadline
- **Polish (Phase 9)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (Core Creation)**: Foundation only - can implement immediately after Phase 2
- **US2 (Authentication)**: Builds on US1 controller (before_action already added)
- **US3 (Validation)**: Builds on US1 models (validations already added)
- **US4 (Form Display)**: Builds on US1 views (form already created)
- **US5 (Single-Choice)**: Foundation only - can implement in parallel with US1-US4
- **US6 (Deadline)**: Builds on US1 models/views (deadline fields already added)

### Critical Path

1. Setup → Foundational → **US1** (MVP - core poll creation)
2. US1 → US2 (authentication verification)
3. US1 → US3 (validation testing)
4. US1 → US4 (form display verification)
5. Foundation → US5 (selection type - can be parallel)
6. US1 → US6 (deadline testing)
7. All US → Polish

### Parallel Opportunities

**Phase 1 (Setup)**: All tasks can run in parallel (T003 and T004 are independent)

**Phase 2 (Foundational)**:
- Poll model work (T005-T013) and Answer model work (T014-T021) are independent - can run in parallel

**Phase 3 (US1 - after Foundational complete)**:
- T022 and T023 (request specs) can run in parallel
- T039 and T040 (i18n files) can run in parallel

**Phase 4-8 (User Stories after US1)**:
- US5 (single-choice) can run in parallel with US2, US3, US4, US6 (independent model enhancement)
- US2 and US4 can run in parallel (authentication vs form display)
- US3 and US6 can run in parallel if different developers (both test validations but different aspects)

**Phase 9 (Polish)**: T090 and T091 can run in parallel

### Within Each Phase - TDD Workflow

**CRITICAL TDD PATTERN - MUST FOLLOW**:

1. **Write spec** (Red phase)
2. **Run spec** → Verify it FAILS
3. **Implement code** (Green phase)
4. **Run spec** → Verify it PASSES
5. **Run RuboCop** → Fix offenses
6. **Commit**

Example for Poll model:
```
T005 (write spec) → T006 (run - FAIL) → T007-T011 (implement) → T012 (run - PASS) → T013 (RuboCop) → commit
```

---

## Parallel Example: Phase 2 (Foundational)

```bash
# Developer A: Poll Model
T005-T013: Poll model spec → implementation → RuboCop

# Developer B: Answer Model (can work simultaneously)
T014-T021: Answer model spec → implementation → RuboCop
```

## Parallel Example: After US1 Complete

```bash
# Developer A: US2 (Authentication)
T044-T049: Authentication request/system specs

# Developer B: US5 (Single-Choice)
T069-T077: Selection type model enhancement

# Developer C: US4 (Form Display)
T060-T068: Form display specs and view refinements
```

---

## Implementation Strategy

### MVP First (Recommended - US1 Only)

1. Phase 1: Setup (T001-T004) - 30 minutes
2. Phase 2: Foundational (T005-T021) - 2-3 hours
3. Phase 3: User Story 1 (T022-T043) - 3-4 hours
4. **STOP and VALIDATE**: Run all tests, create poll manually, verify database
5. **MVP COMPLETE**: Authenticated users can create polls with 4 answers

Total MVP time: **1 day** for experienced Rails developer

### Full Feature Implementation

1. Setup + Foundational → 3-4 hours
2. US1 → 3-4 hours (MVP checkpoint)
3. US2 → 1 hour
4. US3 → 1-2 hours
5. US4 → 1 hour
6. US5 → 1 hour
7. US6 → 1-2 hours
8. Polish → 2 hours

Total time: **2 days** for experienced Rails developer

### Incremental Delivery Strategy

**Day 1**: Setup + Foundational + US1 → Deploy MVP (core poll creation)
**Day 2 AM**: US2 + US3 → Deploy update (authentication + validation hardening)
**Day 2 PM**: US4 + US5 + US6 → Deploy update (UI polish + deadline feature)
**Day 3**: Polish + QA → Final deployment

Each deployment is independently valuable and testable.

---

## Task Summary

- **Total Tasks**: 96 tasks
- **Phase 1 (Setup)**: 4 tasks
- **Phase 2 (Foundational)**: 17 tasks (CRITICAL - blocks all user stories)
- **Phase 3 (US1 - MVP)**: 22 tasks
- **Phase 4 (US2)**: 6 tasks
- **Phase 5 (US3)**: 10 tasks
- **Phase 6 (US4)**: 9 tasks
- **Phase 7 (US5)**: 9 tasks
- **Phase 8 (US6)**: 9 tasks
- **Phase 9 (Polish)**: 10 tasks

**Parallel-able Tasks**: 8 tasks marked [P]
**User Story Labels**: US1 (22 tasks), US2 (6 tasks), US3 (10 tasks), US4 (9 tasks), US5 (9 tasks), US6 (9 tasks)

---

## Success Criteria Validation

After completing all tasks, verify these success criteria from spec.md:

- ✅ **SC-001**: Authenticated users can create a poll with 1 question and 4 answers in under 2 minutes
- ✅ **SC-002**: 95% of poll creation attempts with valid data succeed on first submission
- ✅ **SC-003**: System prevents 100% of unauthenticated poll creation attempts by redirecting to login
- ✅ **SC-004**: All created polls are correctly associated with their creator (user)
- ✅ **SC-005**: Validation errors are displayed to users within 1 second of form submission
- ✅ **SC-006**: Users successfully create a valid poll without errors on first attempt 80% of the time
- ✅ **SC-007**: Poll creation form is accessible and functional across major browsers (Chrome, Firefox, Safari, Edge)
- ✅ **SC-008**: Users can optionally set a poll deadline in under 30 seconds
- ✅ **SC-009**: System prevents 100% of attempts to create polls with past deadlines

---

## Notes

- **TDD MANDATORY**: Write specs before implementation (Constitution Principle II)
- **RuboCop MANDATORY**: Fix all offenses before committing (Constitution Principle XII)
- **I18n MANDATORY**: All user-facing text in locale files (Constitution Principles III, IX, X)
- **Request Spec Organization**: Use organized pattern (spec/requests/polls/[http_method]_[action]_spec.rb)
- **Sign-in Scope**: Always use `sign_in user, scope: :user` in specs (Devise requirement)
- **Nested Attributes**: Use `accepts_nested_attributes_for :answers` (research.md pattern)
- **Answer Uniqueness**: Case-insensitive validation (research.md pattern)
- **Deadline Validation**: Use `Time.current` not `Time.now` (timezone-aware)
- **Flash Messages**: Use `flash.now[:alert]` with re-render, `notice:` with redirect
- **Status Code**: Use `:unprocessable_entity` for validation failures
- **Database Transactions**: Nested attributes save in single transaction (automatic)
- **Checkpoint Testing**: After each phase, manually test the functionality before proceeding
- **MVP Mindset**: US1 alone is a complete, shippable feature - deploy early, iterate based on feedback
