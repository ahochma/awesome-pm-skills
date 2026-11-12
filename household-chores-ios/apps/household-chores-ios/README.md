# Household Chores iOS App

This folder contains a SwiftUI + SwiftData + EventKit MVP scaffold for chore gamification.

## Open in Xcode

Open this project directly:

1. Open `apps/household-chores-ios/HouseholdChoresApp.xcodeproj`.
2. Select scheme `HouseholdChoresApp`.
3. Choose an iOS Simulator.
4. Build and Run.

## Verified locally

- `xcodebuild ... build` passes for iOS Simulator.
- `xcodebuild ... test` passes on simulator (`iPhone 17`).

## Runtime permissions

Info.plist permission keys are already configured in project settings:

- `NSCalendarsFullAccessUsageDescription`
- `NSCalendarsWriteOnlyUsageDescription`

## Regenerate project (optional)

If you edit `project.yml`, regenerate with:

`./.tools/xcodegen/xcodegen/bin/xcodegen generate --spec project.yml`
