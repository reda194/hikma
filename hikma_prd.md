# HIKMA — حكمة
## Hadith Reminder App for macOS
### Product Requirements Document (PRD)
**Version 1.0 | February 2026**

---

| Field | Details |
|-------|---------|
| Project Name | Hikma (حكمة) — Hadith Reminder |
| Platform | macOS Desktop (Mac App Store target) |
| Framework | Flutter (macOS Desktop) + BLoC |
| Language | Arabic (primary) — English planned later |
| Status | v1.0 Personal Build — App Store ready structure |
| Author | Reda — Creative Team Manager, Ramz Al-Aamal IT |

---

## 1. Vision & Purpose

Hikma is a lightweight macOS application that silently lives in the background and delivers authentic Hadith (Prophetic narrations) to the user at scheduled intervals. The concept mirrors existing Quran reader apps on macOS, but focuses exclusively on Sunnah — bringing the words of the Prophet Muhammad (peace be upon him) to the user's screen in a beautiful, non-intrusive popup.

The app is designed to be a daily companion, not a heavy resource. It should feel native to macOS, elegant in appearance, and spiritually meaningful in purpose.

---

## 2. Target Users

### Primary User
The developer himself (Reda) — a Muslim professional seeking daily Hadith reminders during work hours on macOS.

### Secondary Users (Post-MVP)
- Arabic-speaking Muslim professionals using macOS
- Muslims seeking to memorize Hadith gradually through repetition
- Islamic education students who want passive Hadith exposure

---

## 3. Core Concept

The app runs silently in the background. At user-defined intervals, a beautiful floating popup appears on screen displaying a single Hadith in Arabic. The user reads it, optionally saves it, and dismisses it. That is the entire experience.

Nothing more. Nothing less. Simple, focused, and spiritually purposeful.

---

## 4. Features

| Feature | Description | Priority |
|---------|-------------|----------|
| Scheduled Popup | Hadith appears automatically at user-set intervals (e.g., every 1 hour) | Must Have |
| Hadith Display | Full Hadith text in Arabic with narrator name and source book | Must Have |
| Auto-Dismiss Timer | Popup closes automatically after user-set duration (e.g., 1–5 mins) | Must Have |
| Manual Dismiss | User can close the popup immediately with one click | Must Have |
| Favorites / Bookmark | Save any Hadith to a personal favorites list inside the app | Must Have |
| Menu Bar Icon | Persistent icon in macOS menu bar for quick access and settings | Must Have |
| Draggable Popup | User can drag the popup to any position on screen | Must Have |
| Offline Fallback | Bundled local Hadith JSON for use without internet connection | Must Have |
| Online API Mode | Fetch Hadiths from verified external API when online | Must Have |
| Source Selection | Choose Hadith collections (Bukhari, Muslim, Abu Dawud, etc.) | Must Have |
| Font Size Control | Adjustable Arabic font size for readability comfort | Should Have |
| Popup Position Memory | App remembers where user placed the popup last time | Should Have |
| Daily Featured Hadith | One special Hadith pinned for the entire day, separate from timed ones | Should Have |
| Hadith Counter | Shows how many Hadiths read today / this week | Should Have |
| Contemplation Mode | Manual full-screen calm view for focused reading | Should Have |
| Notification Sound | Optional soft notification sound when popup appears | Could Have |
| English Translation | Optional English translation toggle (future version) | Future |

---

## 5. Architecture & Technology Stack

### 5.1 Framework Decision

Flutter (macOS Desktop) is chosen because:
- Reda already knows Flutter + BLoC from mobile development
- Same codebase can later target iOS and Android with minimal changes
- Strong foundation for App Store submission on both Mac App Store and Apple App Store
- BLoC ensures clean separation of UI, business logic, and data

### 5.2 Technology Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter (macOS Desktop) |
| State Management | BLoC (flutter_bloc package) |
| Local Storage | Hive (settings + favorites) |
| Offline Data | Bundled JSON file with ~500 curated Hadiths |
| Online Data | Hadith API (api.hadith.gading.dev or ahadith.co) |
| HTTP Client | dio package |
| Notifications / Timer | Flutter Timer + macOS local notifications |
| Font | Noto Naskh Arabic (Google Fonts) |

### 5.3 Project Folder Structure

```
lib/
  ├── core/           ← constants, theme, utils
  ├── data/           ← models, repositories, APIs
  ├── bloc/           ← BLoC files per feature
  ├── ui/             ← screens, widgets, popup
  └── main.dart
```

---

## 6. Data Strategy

### 6.1 Offline Bundle

Ship the app with a curated local JSON file containing approximately 200–500 Hadiths from the most trusted collections. This file is the safety net — the app always works, even without internet.

JSON structure per Hadith:
```json
{
  "id": 1,
  "text_ar": "...",
  "narrator": "...",
  "book": "Bukhari",
  "chapter": "..."
}
```

### 6.2 Online API

When internet is available, fetch fresh Hadiths from a verified free API. Recommended: `api.hadith.gading.dev` (supports Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah, Nasa'i).

The app checks connectivity on launch:
- **Online:** use API and cache results locally
- **Offline:** fall back to local bundle silently — user never sees an error

### 6.3 Hadith Collections Available

- Sahih Al-Bukhari (البخاري)
- Sahih Muslim (مسلم)
- Sunan Abu Dawud (أبو داود)
- Jami' Al-Tirmidhi (الترمذي)
- Sunan Ibn Majah (ابن ماجه)
- Sunan Al-Nasa'i (النسائي)
- All Collections (random mix) — default option

---

## 7. User Settings

All settings are stored locally. The settings screen is accessible from the Menu Bar icon.

| Setting | Options | Default |
|---------|---------|---------|
| Reminder Interval | 30 min / 1h / 2h / 4h / 8h / Daily | 1 hour |
| Popup Duration | 30s / 1 min / 2 min / 5 min / Manual only | 2 minutes |
| Hadith Source | All / Bukhari / Muslim / Abu Dawud / etc. | All Collections |
| Font Size | Small / Medium / Large / Extra Large | Large |
| Popup Position | Draggable — position saved automatically | Center Screen |
| Sound Alert | On / Off | Off |
| Auto-start on Login | On / Off | On |
| Data Mode | Auto (online first, offline fallback) | Auto |

---

## 8. UI / UX Design Guidelines

### 8.1 Design Philosophy

Minimal. Spiritual. Native macOS feel. No green Islamic clichés. No excessive ornamentation. Think: Apple Notes meets a calm Islamic library.

### 8.2 The Popup Window

- Size: approximately 480px wide, height adapts to Hadith length
- Background: frosted glass / semi-transparent effect
- Border radius: 16px — soft and modern
- Shadow: subtle drop shadow, not harsh
- Arabic text: right-to-left, Noto Naskh Arabic, Large size by default
- Source line: smaller text below — narrator name and book title
- Two buttons only: Bookmark (star icon) and Dismiss (x icon)
- Fully draggable anywhere on screen
- Position persists between sessions

### 8.3 Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Primary | Deep Navy Blue | `#1B4F72` |
| Secondary | Emerald Green | `#117A65` |
| Background | Near White | `#F8F9FA` |
| Text | Dark Charcoal | `#2C3E50` |
| Accent | Pale Blue | `#EAF2F8` |

### 8.4 Menu Bar Behavior

- Small crescent moon icon in the macOS menu bar
- Left click: show current Hadith inline or open popup
- Right click: Settings, Favorites, About, Quit
- The app does NOT appear in the Dock by default (menu bar only)
- Option in settings to show in Dock if user prefers

---

## 9. App Store Readiness

### 9.1 Mac App Store Requirements

- App must be sandboxed (macOS entitlements configured)
- Signed with Apple Developer certificate
- No private APIs — Flutter macOS uses only public APIs
- Privacy: no user data collected or transmitted
- Network access entitlement required for API calls

### 9.2 Future: iOS / Android

Because Flutter is cross-platform, the same BLoC logic and data layer can power iOS and Android apps later. Only the UI layer (popup behavior, menu bar) needs platform-specific adaptation.

### 9.3 App Store Listing Notes

- Category: Lifestyle / Education
- Keywords: Hadith, Islamic, Muslim, Sunnah, Arabic, Daily Reminder
- No in-app purchases in v1.0
- Free on App Store

---

## 10. Development Phases

| Phase | Name | Deliverables | Est. Time |
|-------|------|-------------|-----------|
| Phase 1 | Project Setup | Flutter macOS project created, BLoC structure, folder architecture, fonts configured | 1 day |
| Phase 2 | Data Layer | Hadith model, local JSON bundle (200 Hadiths), API integration with offline fallback | 2 days |
| Phase 3 | Core Popup | Floating popup window, Arabic text display, draggable, auto-dismiss timer, bookmark button | 3 days |
| Phase 4 | Menu Bar | Menu bar icon, right-click menu, settings access, quick Hadith view | 2 days |
| Phase 5 | Settings Screen | All settings (interval, duration, source, font size, sound), saved locally with Hive | 2 days |
| Phase 6 | Favorites Screen | Saved Hadiths list, delete from favorites, share Hadith (future) | 1 day |
| Phase 7 | Polish & Testing | Design refinement, animation, error handling, macOS entitlements, sandbox testing | 3 days |
| Phase 8 | App Store Prep | App icon, screenshots, App Store listing, signing, submission | 2 days |

**Total estimated time: ~16 working days**

---

## 11. BLoC Architecture Map

| BLoC | Responsibility |
|------|---------------|
| HadithBloc | Fetch Hadith (online/offline), manage current Hadith, handle source filter |
| SchedulerBloc | Manage reminder timer, trigger popup event, track interval settings |
| FavoritesBloc | Add / remove / load favorites from local Hive database |
| SettingsBloc | Load and save all user preferences, emit settings changes to other BLoCs |
| PopupBloc | Control popup visibility, position, auto-dismiss countdown |

---

## 12. Important Technical Notes

### macOS Desktop Specifics for Flutter

- Enable macOS target: run `flutter create --platforms=macos .` in project root
- The popup is a separate Flutter Window — research `window_manager` package for floating window behavior
- Menu bar integration requires `system_tray` Flutter package
- RTL text is natively supported in Flutter — set `textDirection: TextDirection.rtl`
- macOS sandbox requires adding network client entitlement in `macos/Runner/*.entitlements`

### Recommended Flutter Packages

| Package | Purpose |
|---------|---------|
| `window_manager` | Control window position, size, dragging on macOS |
| `system_tray` | Menu bar icon and context menu |
| `flutter_bloc` | BLoC state management |
| `hive_flutter` | Fast local key-value storage for settings and favorites |
| `dio` | HTTP client for API requests |
| `connectivity_plus` | Detect online / offline status |
| `google_fonts` | Noto Naskh Arabic font |
| `flutter_acrylic` | Frosted glass / blur effects on macOS window |

---

## 13. CV-Worthy Achievements in This Project

When this project is complete, it demonstrates:

- Flutter cross-platform expertise: macOS Desktop + future iOS/Android from single codebase
- BLoC architecture at production level with clean separation of concerns
- Native macOS integration: Menu Bar, floating windows, system tray, sandboxing
- Published Mac App Store application
- Arabic RTL application development
- Offline-first architecture with API integration and graceful fallback
- End-to-end ownership: idea → design → development → App Store submission

---

*Hikma — حكمة | Built with intention. Guided by Sunnah.*
