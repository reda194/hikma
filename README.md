# Hikma - Hadith Reminder for macOS

A beautiful macOS desktop application that displays authentic Hadith (Prophetic narrations) through non-intrusive floating popups at scheduled intervals.

## Features

- **Scheduled Popup System** - Hadith appears automatically at user-set intervals (30 minutes to daily)
- **Authentic Content** - Full Arabic text with proper citations from Sahih Bukhari, Sahih Muslim, and other major collections
- **Offline-First** - Bundled collection of curated Hadiths works without internet connection
- **Menu Bar Integration** - Crescent moon icon for quick access to all features
- **Draggable Popup** - Frosted glass window that remembers your preferred position
- **Favorites/Bookmark** - Save your favorite Hadiths to a personal collection
- **Customizable Settings** - Adjust interval, duration, font size, and more
- **Keyboard Shortcuts** - Press Cmd+Shift+H to show a Hadith instantly
- **Auto-Start** - Option to launch automatically at login

## Screenshots

![Hikma Popup](assets/images/screenshot-popup.png)
![Settings Screen](assets/images/screenshot-settings.png)

## Installation

### From Release

1. Download the latest release `.dmg` file
2. Drag Hikma to your Applications folder
3. Launch Hikma from your Applications folder

### From Source

```bash
# Clone the repository
git clone https://github.com/yourusername/hikma.git
cd hikma

# Install dependencies
flutter pub get

# Run the app
flutter run -d macos
```

## Requirements

- macOS 11.0 (Big Sur) or later
- 50MB of available disk space

## Privacy Policy

Hikma respects your privacy:
- No user data is collected or transmitted
- All preferences and favorites are stored locally on your device
- Network access is only used to fetch Hadith content (with offline fallback)
- No analytics or tracking

## Credits

**Hadith Sources**
- API: [api.hadith.gading.dev](https://hadith.gading.dev/)
- Content sourced from authentic collections (Sahih Bukhari, Sahih Muslim, etc.)

**Development**
- Built with Flutter for macOS
- Uses BLoC pattern for state management
- Hive for local data persistence

**License**
MIT License - See LICENSE file for details

## Support

For issues, feature requests, or contributions, please visit [GitHub Issues](https://github.com/yourusername/hikma/issues).

---

*Hikma means "wisdom" in Arabic. May this application bring beneficial knowledge to your daily life.*
