# Product Plan: Newborn Activity Monitor (iOS)

## 1. Strategic Vision (The "Why")

### Problem
New parents are exhausted, overwhelmed, and anxious. They struggle to remember when the baby last ate, slept, or had a diaper change, leading to uncertainty and difficulty in handoffs between caregivers. Existing apps can be clunky or lack intelligent insights.

### Solution
An iOS-first, intelligent baby tracker that reduces cognitive load through one-handed operation, real-time syncing between partners, and AI-driven insights that predict schedules rather than just logging them.

### Vision
*   **Now (MVP):** A rock-solid, crash-proof logger for Feeding, Sleep, and Diapers with instant partner syncing.
*   **Next:** Smart reminders and basic sleep pattern recognition.
*   **Later:** A fully AI-powered parenting assistant that answers questions ("Is this normal?") and proactively manages the baby's schedule.

## 2. The Core Job (Simplicity Test)

**The ONE Job:**
> "Give parents confidence that their baby is on track, with zero friction."

**Success Metric:**
> Time to log an event < 3 seconds. Sync latency < 1 second.

## 3. MVP Scope (Zero to Launch Framework)

We will apply the "Simplicity Forcing Function" to strip features until the core value remains.

### Must Have (MVP - V1.0)
*   **Core Tracking:**
    *   **Feeding:** Breast (L/R timers), Bottle (ml/oz), Solids.
    *   **Sleep:** Start/Stop timer, manual entry.
    *   **Diaper:** Wet, Dirty, Mixed.
*   **Syncing:** Real-time data synchronization between two parents (invite system).
*   **Timeline:** A simple chronological feed of today's events.
*   **Summary:** "Last activity" dashboard (e.g., "Last fed 2h ago").
*   **UX:** Dark mode (critical for night feeds).

### Should Have (V1.1)
*   **Growth:** Weight/Height logging.
*   **Reminders:** Simple time-based alarms (e.g., "Feed every 3 hours").
*   **Widgets:** Lock screen widgets for quick status checks.

### Nice to Have / AI (V2.0)
*   **AI Sleep Prediction:** "Baby will likely be tired in 15 mins."
*   **Siri Shortcuts:** Voice logging.
*   **Data Export:** PDF/CSV for doctors.

## 4. AI-First Considerations (OpenAI Model)

*   **Prediction vs. Logging:** Instead of just a logger, the app should eventually *predict* the next event based on historical patterns.
*   **Natural Language Entry:** "Logged a dirty diaper and 4oz of milk just now" (Voice-to-Text parsing).
*   **Insights:** Use LLMs to analyze patterns and suggest adjustments (e.g., "Nap times are shifting later, consider adjusting bedtime").

## 5. Technical Architecture

*   **Platform:** iOS (Swift, SwiftUI) for a native, high-performance feel.
*   **Data/Sync:** CloudKit (CoreData + CloudKit) or Firebase Firestore.
    *   *Recommendation:* **Firebase Firestore** for easier cross-platform potential later and robust auth/sharing capabilities, or **CloudKit** for a purely Apple-ecosystem privacy-focused approach. Given "easy syncing" is key, Firebase is often faster to implement for sharing.
*   **State Management:** SwiftData (iOS 17+) or CoreData.

## 6. Execution Roadmap

1.  **Project Setup:** Initialize iOS project with SwiftUI.
2.  **Data Model:** Define `Entry` types (Feed, Sleep, Diaper).
3.  **Core UI:** Build the "Dashboard" (Quick Actions) and "Timeline" (List).
4.  **Syncing:** Implement the backend connection.
5.  **Polish:** Dark mode, animations, icons.
