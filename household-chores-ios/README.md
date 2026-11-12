# Household Chores iOS App

This folder contains a SwiftUI + SwiftData + EventKit + CloudKit app for chore gamification with multi-device synchronization.

## Open in Xcode

Open this project directly:

1. Open `HouseholdChoresApp.xcodeproj`.
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

## CloudKit Setup

This app uses CloudKit for automatic synchronization between devices signed into the same iCloud account.

### Initial Setup

1. **Xcode Configuration:**
   - CloudKit capability is already configured in `project.yml`
   - Entitlements file is at `HouseholdChoresApp/HouseholdChoresApp.entitlements`
   - Container ID: `iCloud.com.bmad.householdchores`

2. **Apple Developer Account:**
   - Ensure your Apple Developer account has CloudKit enabled
   - The app will automatically create the CloudKit schema on first run

3. **CloudKit Dashboard:**
   - After first app launch, visit [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
   - Verify the schema matches your models (Person, Chore, Completion, MonthlyResult)
   - Switch from Development to Production environment when ready

### CloudKit Limits (Free Tier)

- **Storage:** 1GB per user (plenty for this use case)
- **Transfer:** 2GB per day (more than sufficient)
- **Requests:** 40 requests/second (handled automatically by SwiftData)

### Multi-Device Sync

- Data automatically syncs between devices signed into the same iCloud account
- Changes appear on other devices within seconds (near real-time)
- Works offline - changes are queued and synced when online
- Conflict resolution handled automatically by CloudKit (last-write-wins)

### Privacy

- All data stored in user's private CloudKit database
- Only accessible to devices signed into the same iCloud account
- No backend server needed - CloudKit handles everything

## Regenerate project (optional)

If you edit `project.yml`, regenerate with:

`./.tools/xcodegen/xcodegen/bin/xcodegen generate --spec project.yml`
