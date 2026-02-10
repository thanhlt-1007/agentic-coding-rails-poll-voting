# Tasks: User Registration and Sign Up

**Input**: Design documents from `/specs/001-user-signup/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md)

**Tests**: Optional - system tests will be created following Rails conventions

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Rails application structure
- Models in `app/models/`
- Controllers in `app/controllers/`
- Views in `app/views/`
- Tests in `test/` or `spec/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Install Devise and configure authentication infrastructure

- [X] T001 Add devise gem to Gemfile (~> 4.9)
- [X] T002 Run bundle install to install dependencies
- [X] T003 Run devise installation generator: rails generate devise:install
- [X] T004 Review and configure config/initializers/devise.rb settings
- [X] T005 [P] Configure default URL options in config/environments/development.rb
- [X] T006 [P] Verify root route exists or create placeholder in config/routes.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create User model and database schema - MUST be complete before ANY user story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T007 Generate Devise User model: rails generate devise User
- [ ] T008 Review generated migration in db/migrate/[timestamp]_devise_create_users.rb
- [ ] T009 Run database migration: rails db:migrate
- [ ] T010 Verify User model in app/models/user.rb has required Devise modules
- [ ] T011 Configure Devise modules (database_authenticatable, registerable, validatable)
- [ ] T012 Add Devise routes to config/routes.rb with custom path for sign_up

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - New User Account Creation (Priority: P1) 🎯 MVP

**Goal**: Allow visitors to create accounts at /sign_up with email and password, auto sign-in after registration

**Independent Test**: Visit /sign_up, enter valid email and password, verify account created and user signed in

### Implementation for User Story 1

- [ ] T013 [US1] Generate Devise views: rails generate devise:views
- [ ] T014 [US1] Customize app/views/devise/registrations/new.html.erb sign-up form
- [ ] T015 [US1] Apply Tailwind CSS classes to form in new.html.erb
- [ ] T016 [US1] Add email field with proper label and styling
- [ ] T017 [US1] Add password field with proper label and styling
- [ ] T018 [US1] Add password_confirmation field with proper label and styling
- [ ] T019 [US1] Add submit button with Tailwind styling
- [ ] T020 [US1] Verify form uses form_with or form_for with proper model binding
- [ ] T021 [US1] Configure post-registration redirect in app/controllers/application_controller.rb
- [ ] T022 [US1] Test successful account creation manually: visit /sign_up and create account
- [ ] T023 [US1] Verify user is automatically signed in after registration
- [ ] T024 [US1] Verify redirect to root page after successful sign-up

**Checkpoint**: At this point, User Story 1 should be fully functional - users can create accounts

---

## Phase 4: User Story 2 - Sign Up Validation and Error Handling (Priority: P1)

**Goal**: Display clear, specific error messages for invalid sign-up attempts (duplicate email, weak password, missing fields)

**Independent Test**: Attempt sign-up with various invalid inputs, verify appropriate error messages displayed without creating account

### Implementation for User Story 2

- [ ] T025 [US2] Add error message display in app/views/devise/registrations/new.html.erb
- [ ] T026 [US2] Style error messages with Tailwind CSS (red background, clear text)
- [ ] T027 [US2] Verify email uniqueness validation in User model
- [ ] T028 [US2] Verify email format validation in User model
- [ ] T029 [US2] Verify password minimum length validation (6 characters)
- [ ] T030 [US2] Verify password confirmation matching validation
- [ ] T031 [US2] Test duplicate email error: "Email has already been taken"
- [ ] T032 [US2] Test weak password error: password too short message
- [ ] T033 [US2] Test blank fields error: appropriate messages for missing required fields
- [ ] T034 [US2] Test invalid email format error: "Email is invalid"
- [ ] T035 [US2] Verify form preserves user input on validation failure (except password fields)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - account creation with proper validation

---

## Phase 5: User Story 3 - Access to Sign Up Page (Priority: P1)

**Goal**: Ensure /sign_up is accessible and includes navigation from login page

**Independent Test**: Navigate to /sign_up, verify form renders; check login page for sign-up link

### Implementation for User Story 3

- [ ] T036 [P] [US3] Verify /sign_up route is properly configured in config/routes.rb
- [ ] T037 [P] [US3] Add "Sign up" link to login page (app/views/devise/sessions/new.html.erb)
- [ ] T038 [US3] Test direct access to /sign_up URL loads registration form
- [ ] T039 [US3] Verify form displays email label clearly
- [ ] T040 [US3] Verify form displays password label clearly
- [ ] T041 [US3] Verify form displays password_confirmation label clearly
- [ ] T042 [US3] Test responsive design on mobile viewport
- [ ] T043 [US3] Add navigation link to sign-up in main layout (if applicable)

**Checkpoint**: All access points to sign-up page are working

---

## Phase 6: User Story 4 - Password Confirmation (Priority: P2)

**Goal**: Require password confirmation field to prevent typos

**Independent Test**: Attempt sign-up with matching and mismatched password confirmations

### Implementation for User Story 4

- [ ] T044 [US4] Verify password_confirmation field exists in form (already added in T018)
- [ ] T045 [US4] Verify Devise validates password confirmation matches
- [ ] T046 [US4] Test successful sign-up with matching passwords
- [ ] T047 [US4] Test failed sign-up with mismatched passwords
- [ ] T048 [US4] Verify error message: "Password confirmation doesn't match Password"

**Checkpoint**: Password confirmation working correctly

---

## Phase 7: User Story 5 - Existing User Navigation (Priority: P3)

**Goal**: Add link from sign-up page to login page for existing users

**Independent Test**: View sign-up page and verify "Already have an account? Sign in" link is present and works

### Implementation for User Story 5

- [ ] T049 [US5] Add "Already have an account?" text to app/views/devise/registrations/new.html.erb
- [ ] T050 [US5] Add "Sign in" link pointing to login page (new_user_session_path)
- [ ] T051 [US5] Style the link with Tailwind CSS
- [ ] T052 [US5] Test clicking the link redirects to login page
- [ ] T053 [US5] Verify link is visible and properly positioned on the page

**Checkpoint**: All user stories should now be independently functional

---

## Phase 8: Testing & Edge Cases

**Purpose**: Comprehensive testing and edge case handling

- [ ] T054 [P] Write User model test in test/models/user_test.rb
- [ ] T055 [P] Test email uniqueness (case-insensitive) in user_test.rb
- [ ] T056 [P] Test email format validation in user_test.rb
- [ ] T057 [P] Test password minimum length validation in user_test.rb
- [ ] T058 [P] Write system test in test/system/user_signup_test.rb
- [ ] T059 [P] System test: successful sign-up flow
- [ ] T060 [P] System test: duplicate email error
- [ ] T061 [P] System test: weak password error
- [ ] T062 [P] System test: blank fields error
- [ ] T063 [P] System test: password confirmation mismatch error
- [ ] T064 [P] System test: navigation from sign-up to login
- [ ] T065 Test edge case: email with different case (User@Example.com vs user@example.com)
- [ ] T066 Test edge case: very long email address (255+ characters)
- [ ] T067 Test edge case: very long password (100+ characters)
- [ ] T068 Test edge case: special characters in email
- [ ] T069 Test edge case: already authenticated user accessing /sign_up
- [ ] T070 Handle already-signed-in user by redirecting or showing message

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Security, documentation, and final improvements

- [ ] T071 [P] Verify passwords are encrypted with bcrypt (check database)
- [ ] T072 [P] Verify no plain-text passwords in database
- [ ] T073 [P] Verify CSRF protection is enabled (Rails default)
- [ ] T074 [P] Add client-side form validation to prevent double-submission
- [ ] T075 [P] Test form submission multiple times in quick succession
- [ ] T076 [P] Update README.md with authentication setup instructions
- [ ] T077 [P] Document Devise configuration in README or docs/
- [ ] T078 [P] Verify HTTPS requirement for production environment
- [ ] T079 Code review: Check all Devise security best practices
- [ ] T080 Final manual testing of all user stories end-to-end
- [ ] T081 Run full Rails test suite: rails test or rspec
- [ ] T082 Performance test: measure page load time (target < 500ms)
- [ ] T083 Performance test: measure form submission time (target < 1s)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup (Phase 1) - BLOCKS all user stories
- **User Stories (Phases 3-7)**: All depend on Foundational phase completion
  - User stories can proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 stories first, then P2, then P3)
- **Testing (Phase 8)**: Can start after respective user stories complete
- **Polish (Phase 9)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1 - T013-T024)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1 - T025-T035)**: Enhances US1 but independently testable
- **User Story 3 (P1 - T036-T043)**: Can run parallel with US1 and US2
- **User Story 4 (P2 - T044-T048)**: Mostly validation of existing functionality
- **User Story 5 (P3 - T049-T053)**: Simple navigation addition, no dependencies

### Within Each Phase

- Setup: T001 → T002 → T003 → T004, then T005 and T006 can run in parallel
- Foundational: Must run sequentially (T007 → T008 → T009 → T010 → T011 → T012)
- User Story 1: T013 → T014 → T015-T020 (can parallelize styling tasks) → T021 → T022-T024
- User Story 2: T025-T026 (can be parallel) → T027-T035 (testing tasks)
- User Story 3: T036-T037 can run in parallel, then T038-T043
- Testing Phase: All tasks marked [P] can run in parallel
- Polish Phase: Most tasks marked [P] can run in parallel

### Parallel Opportunities

Within phases, tasks marked [P] can execute concurrently:

**Setup Phase:**
```
After T004 completes:
- T005 (configure development.rb) || T006 (routes.rb)
```

**User Story 3:**
```
- T036 (verify route) || T037 (add link to login page)
```

**Testing Phase:**
```
All model tests in parallel:
- T054 || T055 || T056 || T057

All system tests in parallel:
- T058 || T059 || T060 || T061 || T062 || T063 || T064
```

**Polish Phase:**
```
All documentation and verification tasks:
- T071 || T072 || T073 || T074 || T076 || T077 || T078
```

---

## Implementation Strategy

### MVP First (User Stories 1-3 Only - All P1)

1. **Complete Phase 1**: Setup (T001-T006)
2. **Complete Phase 2**: Foundational (T007-T012) - CRITICAL checkpoint
3. **Complete Phase 3**: User Story 1 (T013-T024)
4. **Complete Phase 4**: User Story 2 (T025-T035)
5. **Complete Phase 5**: User Story 3 (T036-T043)
6. **STOP and VALIDATE**: Test all P1 user stories independently
7. **Optional**: Skip to Phase 8 for core testing (T054-T064)
8. Deploy/demo MVP

**MVP Deliverable**: Functional user registration at /sign_up with validation and proper navigation

### Incremental Delivery

1. **Foundation** (Phases 1-2) → Devise installed and configured
2. **Add US1** (Phase 3) → Basic sign-up working
3. **Add US2** (Phase 4) → Validation working
4. **Add US3** (Phase 5) → Navigation complete → **MVP READY**
5. **Add US4** (Phase 6) → Password confirmation verified
6. **Add US5** (Phase 7) → Full navigation
7. **Testing** (Phase 8) → Comprehensive test coverage
8. **Polish** (Phase 9) → Production-ready

### Parallel Team Strategy

With multiple developers (after Foundational Phase 2 completes):

- **Developer A**: User Story 1 + User Story 2 (T013-T035)
- **Developer B**: User Story 3 + User Story 5 (T036-T043, T049-T053)
- **Developer C**: User Story 4 + Testing setup (T044-T048, T054-T064)
- **All together**: Polish phase (T071-T083)

---

## Validation Checklist

After completing all tasks, verify:

- ✅ `/sign_up` route is accessible
- ✅ Sign-up form displays with all required fields
- ✅ Valid credentials create account and auto sign-in
- ✅ Invalid inputs show appropriate error messages
- ✅ Duplicate email prevents account creation
- ✅ Password too short shows error
- ✅ Missing fields show errors
- ✅ Password confirmation mismatch shows error
- ✅ Navigation between sign-up and login pages works
- ✅ Passwords are encrypted in database
- ✅ All user stories from spec.md are satisfied
- ✅ All success criteria from spec.md are met

---

## Notes

- Tasks are organized by user story for independent delivery
- Each user story can be tested independently after completion
- [P] indicates parallelizable tasks (different files, no dependencies)
- [US#] labels link tasks to user stories in spec.md
- Commit after each logical task group
- Stop at checkpoints to validate independently
- Devise provides most functionality out-of-box, tasks focus on customization and validation

---

## Total Task Count

- **Setup**: 6 tasks
- **Foundational**: 6 tasks
- **User Story 1**: 12 tasks
- **User Story 2**: 11 tasks
- **User Story 3**: 8 tasks
- **User Story 4**: 5 tasks
- **User Story 5**: 5 tasks
- **Testing**: 17 tasks
- **Polish**: 13 tasks

**Total**: 83 tasks

**MVP Scope** (P1 only): 36 tasks (Phases 1-5)

**Parallel Opportunities**: 35+ tasks can run in parallel across phases
