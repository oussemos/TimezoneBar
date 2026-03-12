# TimezoneBar

A lightweight macOS menu bar app that displays multiple clocks for different time zones side by side.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow)

## Features

- **Live clocks in the menu bar** — all your configured timezones shown next to each other, updated every second
- **Quick add / remove** — click the menu bar icon to open the popover, then hit `+` to add a timezone or `×` to remove one
- **Per-clock formatting** — 12/24-hour, show seconds, show date, show/hide the label prefix
- **Reorder clocks** — drag rows in Preferences (`⌘,`) to change the display order
- **Persistent** — all settings saved in UserDefaults and restored on next launch
- **No Dock icon** — lives entirely in the menu bar

## Requirements

- macOS 14 (Sonoma) or later
- Xcode Command Line Tools / Swift toolchain

## Build & Run

```bash
./build.sh
```

This compiles a release build and packages it as `TimezoneBar.app` in the project directory. The script will ask if you want to launch it immediately.

To install permanently, drag `TimezoneBar.app` to `/Applications/`.

### Manual build steps

```bash
swift build -c release
mkdir -p TimezoneBar.app/Contents/MacOS
cp .build/release/TimezoneBar TimezoneBar.app/Contents/MacOS/
cp Info.plist TimezoneBar.app/Contents/


```

## Usage

| Action | How |
|---|---|
| View all clocks | Click the menu bar item |
| Add a timezone | Click menu bar item → **Add Timezone** |
| Remove a timezone | Click menu bar item → **×** next to a clock |
| Edit a clock (name, format) | `⌘,` → **Edit** |
| Reorder clocks | `⌘,` → drag rows |
| Quit | Click menu bar item → **Quit** |

## Project Structure

```
Sources/TimezoneBar/
├── TimezoneBarApp.swift          # @main, MenuBarExtra scene
├── ClockConfig.swift             # Clock data model
├── ClockManager.swift            # State, 1s timer, UserDefaults persistence
└── Views/
    ├── MenuBarContentView.swift  # Popover (add/remove/view clocks)
    ├── ClockRowView.swift        # Individual clock display
    ├── PreferencesView.swift     # Settings window (reorder, edit, delete)
    └── AddEditClockView.swift    # Add / edit clock form
```
