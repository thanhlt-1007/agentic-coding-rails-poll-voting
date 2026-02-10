# Feature Specification: Poll Voting System

**Feature Branch**: `001-poll-voting-system`  
**Created**: February 10, 2026  
**Status**: Draft  
**Input**: User description: "Xây dựng hệ thống tạo Poll, mời người khác vote, chốt kết quả theo deadline. Chủ poll tạo câu hỏi, lựa chọn, đặt deadline; người dùng nhận link/mã tham gia, vote một lần; kết quả hiển thị thời gian thực (ẩn/hiện theo cấu hình)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Poll Creator Creates and Publishes Poll (Priority: P1)

A poll creator wants to create a poll with a question, multiple choice options, and a deadline, then share it with participants.

**Why this priority**: This is the foundation of the entire system - without the ability to create and publish polls, no other functionality is possible. This delivers immediate value as a standalone feature.

**Independent Test**: Can be fully tested by creating a poll with question "What's your favorite color?", choices ["Red", "Blue", "Green"], deadline "February 15, 2026 5:00 PM", receiving a shareable link, and verifying the poll is accessible via that link. Delivers value: poll creator can gather votes immediately.

**Acceptance Scenarios**:

1. **Given** user is on poll creation page, **When** user enters question "What's for lunch?", adds choices "Pizza", "Sushi", "Burgers", sets deadline to tomorrow 12:00 PM, **Then** system creates poll and provides shareable link
2. **Given** user creates poll with 2 choices minimum, **When** user saves poll, **Then** poll is saved with unique identifier and access code
3. **Given** poll creator sets deadline to past date, **When** user tries to save poll, **Then** system shows validation error "Deadline must be in the future"
4. **Given** poll creator adds only 1 choice option, **When** user tries to save poll, **Then** system shows validation error "Poll must have at least 2 choices"
5. **Given** poll is successfully created, **When** poll creator receives link, **Then** link format is `[app-url]/polls/[unique-code]` (e.g., `/polls/ABC123`)

---

### User Story 2 - Participant Votes on Poll (Priority: P1)

A participant receives a poll link or access code, views the poll question and choices, submits one vote, and sees confirmation.

**Why this priority**: Voting is the core interaction - without voting capability, the poll system has no purpose. This is the second critical slice needed for MVP (create poll → vote on poll).

**Independent Test**: Can be tested independently by opening a poll link `/polls/ABC123`, seeing question and choices, selecting one option, clicking "Submit Vote", and receiving confirmation "Your vote has been recorded". Delivers value: participants can express their opinion immediately.

**Acceptance Scenarios**:

1. **Given** participant opens poll link `/polls/ABC123`, **When** poll is active (before deadline), **Then** participant sees poll question, all choice options, and time remaining until deadline
2. **Given** participant views active poll, **When** participant selects one choice and clicks "Submit Vote", **Then** vote is recorded and participant sees confirmation message "Thank you for voting!"
3. **Given** participant has already voted on poll ABC123, **When** participant opens same poll link again, **Then** system shows message "You have already voted on this poll" and displays participant's previous choice
4. **Given** participant opens poll link after deadline has passed, **When** page loads, **Then** system shows message "This poll has closed" and displays final results
5. **Given** participant opens invalid poll link `/polls/INVALID`, **When** page loads, **Then** system shows 404 error "Poll not found"

---

### User Story 3 - Real-Time Results Display (Priority: P2)

Poll creator and participants view voting results in real-time with live updates as new votes come in, with visibility controlled by poll configuration.

**Why this priority**: Real-time feedback enhances user engagement and provides immediate value, but the system can function without it (results can be shown after deadline). This is a valuable enhancement to P1 stories.

**Independent Test**: Can be tested by creating poll with "Show results while voting" enabled, opening poll in two browser windows, casting vote in window 1, and verifying window 2 updates automatically without refresh. Delivers value: transparency and engagement during voting period.

**Acceptance Scenarios**:

1. **Given** poll creator creates poll with setting "Show results while voting: Yes", **When** any participant votes, **Then** all viewers see updated vote counts immediately (within 2 seconds) without page refresh
2. **Given** poll creator creates poll with setting "Show results while voting: No", **When** participants are voting, **Then** vote counts are hidden and only visible after deadline passes
3. **Given** user is viewing poll results page, **When** vote counts update, **Then** changes are visually highlighted (e.g., animation on count increase)
4. **Given** poll has received votes, **When** results are displayed, **Then** each choice shows vote count and percentage of total votes (e.g., "Pizza: 15 votes (45%)")
5. **Given** poll deadline has passed, **When** anyone views poll, **Then** final results are always visible regardless of "Show results while voting" setting

---

### User Story 4 - Poll Management and Closure (Priority: P3)

Poll creator can edit poll details before any votes are cast, manually close poll early, and view final statistics after deadline.

**Why this priority**: Management features improve creator control but aren't essential for core voting workflow. System delivers full value with P1-P2 stories alone.

**Independent Test**: Can be tested by creating poll, editing deadline before votes are cast (succeeds), attempting edit after votes exist (blocked or restricted), manually closing poll before deadline, and viewing aggregated statistics page. Delivers value: flexibility for poll creators.

**Acceptance Scenarios**:

1. **Given** poll creator created poll with no votes yet, **When** creator clicks "Edit Poll", **Then** creator can modify question, choices, deadline, and visibility settings
2. **Given** poll has received at least one vote, **When** creator tries to edit poll choices, **Then** system prevents changes to choices and shows message "Cannot modify choices after votes are recorded"
3. **Given** poll is active with deadline in future, **When** creator clicks "Close Poll Now", **Then** poll immediately closes and results become final
4. **Given** poll has closed (deadline passed or manually closed), **When** creator views poll dashboard, **Then** creator sees statistics: total votes, votes per choice, voting timeline graph (votes over time)
5. **Given** creator views poll statistics, **When** page loads, **Then** creator sees exportable data (CSV download button with columns: Timestamp, Choice, Vote Count)

---

### Edge Cases

- What happens when poll deadline is exactly now (within same second)? → Poll closes, no new votes accepted
- How does system handle participant voting at exact deadline moment? → Vote timestamp compared to deadline; if vote submitted before deadline passes, it counts
- What happens when participant loses internet connection during vote submission? → Vote submission fails gracefully with error message "Connection lost. Please try again."
- How does system handle concurrent votes from different participants? → Database uses atomic transactions to ensure accurate vote counting without race conditions
- What happens when poll creator deletes poll that participants are currently viewing? → Participants see "Poll no longer available" message
- How does system prevent vote manipulation (voting multiple times)? → Uses browser fingerprinting + IP tracking + session cookies (non-authenticated); or user account ID if authenticated
- What happens when poll has 0 votes and deadline passes? → Poll shows "No votes recorded" message with all choices at 0%
- How does system handle extremely long poll questions or choice text? → Truncates display with "..." and shows full text on hover or in expanded view
- What happens when poll has 100+ choices? → Displays choices in scrollable list or paginated view; search/filter functionality recommended
- How does system handle time zones for deadline? → Stores deadline in UTC, displays in participant's local time zone with clear timezone indicator

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow poll creators to create polls with a question (max 500 characters), minimum 2 choice options (each max 200 characters), and a future deadline (date + time)
- **FR-002**: System MUST generate unique shareable link for each poll in format `/polls/[unique-code]` where code is alphanumeric, 6-8 characters, URL-safe
- **FR-003**: System MUST allow participants to submit exactly one vote per poll via link access (no authentication required for MVP)
- **FR-004**: System MUST prevent duplicate voting from same participant using combination of browser session, cookies, and IP address tracking
- **FR-005**: System MUST automatically close poll when deadline is reached (no new votes accepted after deadline timestamp)
- **FR-006**: System MUST display vote results with vote counts and percentages for each choice, formatted as "Choice Name: X votes (Y%)"
- **FR-007**: System MUST support real-time result updates using Turbo Streams (Rails 8 SSR) with updates pushed within 2 seconds of vote submission
- **FR-008**: System MUST allow poll creators to configure result visibility with two options: "Show results while voting" (Yes/No)
- **FR-009**: System MUST display time remaining until deadline in human-readable format (e.g., "2 days 5 hours remaining")
- **FR-010**: System MUST validate poll creation inputs: question required, minimum 2 choices, deadline must be future date
- **FR-011**: System MUST show appropriate messages for closed polls: "This poll has closed. Results:" followed by final vote counts
- **FR-012**: System MUST persist all votes with timestamp, choice ID, and participant identifier (IP hash or session token)
- **FR-013**: System MUST prevent poll choice modification after first vote is recorded to maintain data integrity
- **FR-014**: System MUST allow poll creator to manually close poll before deadline via "Close Poll Now" action
- **FR-015**: System MUST display poll statistics to creator including total votes, votes per choice, participation timeline (if implemented)

### Key Entities

- **Poll**: Represents a voting poll with question, deadline, visibility settings (show results while voting), status (active/closed), creator reference, unique access code, creation timestamp
- **Choice**: Represents one option within a poll; belongs to a poll; has display text, vote count cache, display order
- **Vote**: Represents one participant's vote; belongs to a poll and a choice; has timestamp, participant identifier (hashed IP or session token), validates uniqueness per poll-participant combination
- **Participant**: Implicit entity tracked via browser fingerprint/session (non-authenticated user); identified by hashed combination of IP address + user agent + session cookie

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Poll creators can create and publish a poll in under 60 seconds from start to receiving shareable link
- **SC-002**: Participants can view poll and submit vote in under 15 seconds (excluding poll reading time)
- **SC-003**: Real-time result updates appear within 2 seconds of vote submission for all active viewers
- **SC-004**: System accurately prevents duplicate voting with 99%+ effectiveness (< 1% duplicate vote rate through technical circumvention)
- **SC-005**: Poll automatically closes within 60 seconds of deadline timestamp (acceptable latency for background job processing)
- **SC-006**: System supports at least 100 concurrent voters on a single poll without performance degradation (response time < 500ms for p95)
- **SC-007**: Results display correctly with accurate vote counts and percentages (sum of all percentages = 100% ± 0.1% rounding)
- **SC-008**: 95% of poll creators successfully share poll link and receive at least one vote (measured via analytics)
- **SC-009**: Zero data loss for submitted votes under normal operating conditions (votes persisted to database before confirmation shown)
- **SC-010**: Mobile users can create and vote on polls with same functionality as desktop (responsive design, tested on iOS/Android)

## Assumptions

- **Assumption 1**: Poll creators do not require authentication for MVP (anyone can create poll via `/polls/new`)
- **Assumption 2**: Participants do not require accounts; voting is anonymous based on link access
- **Assumption 3**: Duplicate vote prevention uses technical fingerprinting (IP + session + cookies) rather than user authentication
- **Assumption 4**: Polls remain accessible indefinitely after creation (no automatic deletion of old polls)
- **Assumption 5**: Maximum 50 choice options per poll (reasonable UI limit)
- **Assumption 6**: Maximum 10,000 votes per poll (database scalability assumption)
- **Assumption 7**: Poll creator receives link but no email notification system required for MVP
- **Assumption 8**: Results visibility toggle applies to pre-deadline period only; all polls show results after deadline
- **Assumption 9**: No poll analytics dashboard required for MVP (basic statistics shown on poll page)
- **Assumption 10**: English language interface only for MVP (i18n can be added later)

## Out of Scope

The following features are explicitly **not** included in this specification:

- User authentication and account management (login, registration, profile)
- Email/SMS notifications for poll creation, voting, or deadline reminders
- Poll templates or pre-filled question suggestions
- Multi-language support (i18n)
- Poll categories or tagging system
- Search functionality to find public polls
- Social media sharing integration (Twitter, Facebook share buttons)
- Advanced analytics dashboard (voter demographics, time-series charts)
- Poll comments or discussion threads
- Ranked choice voting or weighted voting systems
- Private polls requiring password or whitelist access
- Poll editing after votes are recorded (besides manual closure)
- Export formats beyond CSV (PDF, Excel, JSON)
- API for third-party integrations
- White-label or custom branding options
- Poll archival or deletion by creators

## Technical Constraints

- Must use Rails 8 with Hotwire/Turbo for SSR and real-time updates (per constitution)
- Must use PostgreSQL for data persistence (per constitution)
- Must use Solid Cache and Solid Queue (no Redis required per constitution)
- Real-time updates via Turbo Streams (no WebSocket libraries outside Rails ecosystem)
- Responsive design with Tailwind CSS (mobile-first approach per constitution)
- Test coverage minimum 90% on models and controllers (per constitution)
- No external JavaScript libraries beyond Rails importmap defaults (per constitution)
- Deployment to Render.com (per constitution and RENDER.md guide)

## Dependencies

- Rails 8.1.2+ with Turbo Rails for real-time SSR updates
- PostgreSQL 15+ for relational data storage (polls, choices, votes)
- Solid Queue for deadline closure background jobs (check expired polls every minute)
- Tailwind CSS 4+ for responsive UI styling
- Stimulus JS for client-side interactions (countdown timer, vote button handling)
- Render.com deployment platform (per project standards)

## Security Considerations

- **Duplicate Vote Prevention**: Implement multi-layer check (session cookie + IP hash + browser fingerprint) stored in votes table
- **Rate Limiting**: Prevent vote spam by limiting votes per IP to 10 votes/minute across all polls
- **Input Validation**: Sanitize all user inputs (poll questions, choice text) to prevent XSS attacks
- **SQL Injection**: Use Rails parameterized queries and Active Record exclusively (per constitution)
- **CSRF Protection**: Rails built-in CSRF tokens enabled for all POST/PUT/DELETE requests (per constitution)
- **Poll Access**: No authentication required but unique codes should be cryptographically random (SecureRandom.urlsafe_base64)
- **Data Privacy**: Store only hashed participant identifiers (SHA256 hash of IP + user agent), not raw IP addresses
- **Deadline Integrity**: Server-side timestamp validation; never trust client-submitted timestamps

## Performance Requirements

- **Page Load Time**: Poll viewing page loads in < 1 second (p95) with 10 choices and 100 votes
- **Vote Submission**: Vote POST request completes in < 300ms (p95) including validation and database write
- **Real-Time Update Latency**: Turbo Stream broadcasts reach connected clients within 2 seconds of vote submission
- **Concurrent Users**: Support 100 simultaneous voters on single poll without degradation (tested via load testing)
- **Database Queries**: Avoid N+1 queries on results page (use eager loading for poll.choices.includes(:votes))
- **Caching**: Cache poll results page for 5 seconds (Solid Cache) to reduce database load on high-traffic polls

## Accessibility Requirements

- All forms must have proper labels and ARIA attributes for screen readers
- Keyboard navigation support (tab order, enter to submit vote)
- Color contrast ratios meet WCAG 2.1 AA standards (4.5:1 for normal text)
- Focus indicators visible on all interactive elements
- Error messages announced to screen readers
- Responsive design supports zoom up to 200% without horizontal scrolling

## Acceptance Criteria Summary

This feature is considered complete when:

1. ✅ Poll creator can create poll with question, ≥2 choices, future deadline, receive shareable link
2. ✅ Participant can vote via link, submit one vote, see confirmation
3. ✅ System prevents duplicate votes from same participant
4. ✅ Poll automatically closes at deadline timestamp
5. ✅ Results display with vote counts and percentages
6. ✅ Real-time updates work via Turbo Streams (< 2 sec latency)
7. ✅ Poll creator can configure result visibility (show/hide while voting)
8. ✅ All edge cases handled gracefully (closed polls, invalid links, network errors)
9. ✅ Test coverage ≥90% on models and controllers
10. ✅ Responsive design works on mobile and desktop
11. ✅ All functional requirements (FR-001 to FR-015) implemented
12. ✅ All success criteria (SC-001 to SC-010) validated through testing
