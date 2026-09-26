# Travel Tracker

An iOS 17 SwiftUI + SwiftData app for logging work trips, expenses and mileage.

## Features

- **Trips** — destination, project/job #, purpose, start/end dates, km driven, notes. Grouped into In Progress, Upcoming and Past, with search.
- **Expenses** — per-trip expenses by category (lodging, meals, transport, fuel, parking, other).
- **Mileage** — reimbursement calculated from km × a configurable rate (default $0.72/km, CRA rate).
- **Summary** — yearly totals by category, days travelling, km driven.
- **CSV export** — one row per expense plus a mileage row per trip, shared via the iOS share sheet.
- **Settings** — currency and mileage rate.

## Building

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open TravelTracker.xcodeproj
```

The GitHub Actions workflow (`.github/workflows/build.yml`) runs the same steps and builds for the iOS Simulator on every push.

## Layout

```
TravelTracker/
  TravelTrackerApp.swift     App entry + SwiftData container
  Models.swift               Trip, Expense, ExpenseCategory
  Settings.swift             Settings keys/defaults, formatting helpers
  Views/
    TripListView.swift       Trip list, search, toolbar
    TripDetailView.swift     Trip details, expenses, totals
    TripEditorView.swift     Add/edit trip
    ExpenseEditorView.swift  Add/edit expense
    SummaryView.swift        Yearly summary + CSV export
    SettingsView.swift       Currency + mileage rate
```
