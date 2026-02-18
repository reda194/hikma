<!--
SYNC IMPACT REPORT
==================
Version change: Initial (0.0.0) -> 1.0.0
Modified principles: N/A (initial creation)
Added sections: All sections (initial creation)
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md (Constitution Check section needs Hikma-specific gates)
  - .specify/templates/spec-template.md (aligned with Hikma requirements)
  - .specify/templates/tasks-template.md (Flutter/BLoC-specific task patterns)
Follow-up TODOs: None
-->

# Hikma Constitution

## Core Principles

### I. Simplicity Over Complexity

Hikma MUST remain a focused, single-purpose application. Every feature addition MUST justify its existence against the core mission: delivering authentic Hadith to users in a non-intrusive way.

- No feature creep: new capabilities MUST either enhance Hadith delivery or improve user experience
- Prefer existing Flutter packages over custom implementations
- Maximum three taps/clicks to access any primary function
- Background resource usage MUST remain under 50MB memory
- Binary size MUST stay under 50MB for Mac App Store approval

**Rationale**: Users seek spiritual focus, not feature bloat. Simplicity ensures reliability and maintainability.

### II. Offline-First Reliability

Hikma MUST function fully without internet connectivity. Online API enhancement is a convenience, not a requirement.

- App ships with bundled local JSON containing 200-500 curated Hadiths
- Offline mode MUST be transparent - no error messages about connectivity
- Online fetches cache results locally for future offline access
- All user settings and favorites persist locally using Hive

**Rationale**: Hadith reminders should not depend on network availability. Users deserve uninterrupted spiritual content.

### III. BLoC Architecture Discipline

State management MUST follow BLoC pattern strictly. No direct state manipulation in widgets.

- Every feature MUST have corresponding Bloc, Event, and State classes
- Business logic resides ONLY in BLoC, never in widgets
- Widget layer is purely reactive - renders state and emits events
- One BLoC per feature domain (HadithBloc, SchedulerBloc, FavoritesBloc, SettingsBloc, PopupBloc)

**Rationale**: BLoC ensures testable, maintainable code with clear separation of concerns - essential for App Store submission and long-term maintenance.

### IV. macOS Native Experience

Hikma MUST feel like a native macOS application, not a ported mobile app.

- Menu bar icon (crescent moon) provides primary app access
- Popup window uses frosted glass/blur effects matching macOS design language
- Support macOS-specific behaviors: draggable windows, position persistence, auto-start on login
- Proper sandboxing and entitlements for Mac App Store submission
- Noto Naskh Arabic font with proper RTL text direction

**Rationale**: Native feel builds user trust and ensures Apple approves the app for Mac App Store distribution.

### V. Authentic & Cited Content

Every Hadith displayed MUST include proper attribution: narrator name, source book, and chapter reference.

- No uncited or unverified Hadith content
- Source selection from authentic collections: Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i
- Hadith text MUST be displayed in Arabic with clear, readable typography
- English translations planned for future but NOT in v1.0 scope

**Rationale**: Authenticity is sacred. Users must trust the content's religious validity.

### VI. Privacy & Respect

Hikma collects NO user data. All preferences remain local to the user's device.

- No analytics, tracking, or telemetry
- No account creation or authentication required
- No cloud sync - favorites and settings are device-local only
- Network access ONLY for fetching Hadith content from verified APIs

**Rationale**: Spiritual content deserves privacy. Users should not be monitored while engaging with religious material.

## Development Workflow

### Feature Addition Process

All new features MUST follow this sequence:

1. **Specification**: Create/update feature spec in `/specs/[feature-name]/spec.md`
2. **Planning**: Run `/speckit.plan` to generate implementation plan
3. **Constitution Check**: Verify proposed changes align with all six principles
4. **Task Breakdown**: Run `/speckit.tasks` to generate actionable tasks
5. **Implementation**: Code following BLoC architecture
6. **Testing**: Verify offline functionality and macOS native behaviors
7. **Review**: Ensure principles are not violated

### Code Quality Standards

- All code MUST follow Flutter/Dart style guidelines (dart format)
- Public APIs MUST be documented with dartdoc comments
- BLoC events and states MUST be immutable (using `freezed` or `equatable`)
- No hardcoded values - use constants from `lib/core/constants/`

### Testing Requirements

Tests are OPTIONAL but when included MUST follow:

- Widget tests for all custom widgets
- BLoC tests for state transitions
- Integration tests for critical user flows (scheduled popup, favorites, settings)
- Tests MUST verify offline-first behavior works correctly

## Technology Constraints

### Approved Dependencies

| Package | Purpose | Version Constraint |
|---------|---------|-------------------|
| flutter_bloc | BLoC state management | ^8.1.0 |
| hive_flutter | Local key-value storage | ^1.1.0 |
| dio | HTTP client for API | ^5.4.0 |
| connectivity_plus | Network status detection | ^5.0.0 |
| google_fonts | Noto Naskh Arabic font | ^6.1.0 |
| window_manager | macOS window control | ^0.3.0 |
| system_tray | Menu bar integration | ^2.0.0 |
| flutter_acrylic | Frosted glass effects | ^1.1.0 |
| equatable | BLoC state equality | ^2.0.5 |

### Forbidden Patterns

- NO direct database access from widgets
- NO `setState()` outside of BLoC-managed widgets
- NO hardcoded Hadith content - all from local JSON or API
- NO platform-specific code outside `lib/platform/` directory
- NO blocking operations on main thread

## Architecture Requirements

### Folder Structure (Enforced)

```
lib/
  ├── core/              # constants, theme, utils (shared across app)
  │   ├── constants/
  │   ├── theme/
  │   └── utils/
  ├── data/              # models, repositories, APIs
  │   ├── models/
  │   ├── repositories/
  │   └── services/
  ├── bloc/              # BLoC files per feature
  │   ├── hadith/
  │   ├── scheduler/
  │   ├── favorites/
  │   ├── settings/
  │   └── popup/
  ├── ui/                # screens, widgets, popup
  │   ├── screens/
  │   ├── widgets/
  │   └── popup/
  └── main.dart
```

### BLoC Contract

Each BLoC MUST implement:
- Event class (abstract base + concrete events)
- State class (immutable with properties for all UI state)
- BLoC class extending `Bloc<Event, State>`
- Initial state defined
- All state transitions explicitly tested

## Governance

### Amendment Procedure

1. Propose amendment with rationale in project discussion
2. Document impact on existing code and templates
3. Update constitution version following semantic versioning
4. Update all dependent templates and documentation
5. Communicate changes to all contributors

### Versioning Policy

- **MAJOR**: Principle removal or backward-incompatible governance changes
- **MINOR**: New principle added or material expansion of existing guidance
- **PATCH**: Clarifications, wording improvements, non-semantic refinements

### Compliance Review

All pull requests MUST verify:
- [ ] Code follows BLoC architecture (Principle III)
- [ ] Offline functionality preserved (Principle II)
- [ ] No new external dependencies without review
- [ ] macOS native behavior maintained (Principle IV)
- [ ] Hadith content properly cited (Principle V)
- [ ] User privacy respected (Principle VI)

### Complexity Justification

Any violation of Simplicity principle (Principle I) MUST be documented with:
- Specific user need requiring complexity
- Simpler alternatives considered and why rejected
- Migration plan if complexity needs future reduction

**Version**: 1.0.0 | **Ratified**: 2026-02-18 | **Last Amended**: 2026-02-18
