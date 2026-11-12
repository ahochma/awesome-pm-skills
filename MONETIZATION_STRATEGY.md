# Monetization Strategy: From Tracker to "Parenting Partner"

## 1. Strategic Vision (The "Why")

### The Problem
New parents are overwhelmed. A simple tracker solves the "memory" problem, but not the "anxiety" problem.
*   **Commodity:** Logging (Free everywhere).
*   **Value:** Insight, Prediction, and Shared Responsibility.

### The Strategic Shift
We are not selling a database. We are selling **sleep and certainty**.
*   **Tactical:** "Log a diaper."
*   **Strategic:** "Know if your baby is hydrated enough so you don't have to call the doctor."

---

## 2. The "Hook" Model (Freemium Strategy)

To drive conversion, we must make the "Free" version indispensable, but the "Paid" version irresistible for specific high-value moments.

### The "Free" Hook (Retention)
*   **Unlimited Logging:** Never gate the core utility (Feed/Sleep/Diaper). If they can't log, they leave.
*   **Basic Stats:** "Today's" summary.
*   **Single Profile:** One baby, one device.
*   **Community Support:** Standard FAQ and documentation.

### The "Paid" Trigger (Conversion)
We gate features that solve **High-Anxiety** or **High-Friction** moments.
1.  **The "Partner" Trigger:** "I'm tired, you take over." -> **Sync requires Premium.**
2.  **The "Doctor" Trigger:** "Is he gaining weight?" -> **Growth Charts & PDF Reports require Premium.**
3.  **The "Sleep" Trigger:** "When will she wake up?" -> **Live Activities & Predictions require Premium.**

---

## 3. Pricing Tiers (Features + Service)

We differentiate not just by *what* they get, but *how* we treat them.

| Tier | Price | Value Prop | Feature Access | Service Level |
| :--- | :--- | :--- | :--- | :--- |
| **Free** | $0 | "Best-in-class Tracker" | Unlimited Logs, Basic Charts, Local Data. | **Self-Serve:** FAQ & Help Docs only. |
| **Plus** | **$4.99/mo** | "Peace of Mind" | **Sync**, Growth Charts, PDF Exports, Live Activities. | **Priority Email:** Response within 24h. <br> **Data Import:** Assistance migrating from other apps. |
| **Pro** | **$19.99/mo** | "Expert Guidance" | All Plus features + **AI Sleep Insights**. | **Expert Access:** Monthly Q&A with Sleep Consultant. <br> **Concierge:** 1-on-1 Onboarding call. |

**Strategic Note:**
The "Pro" tier introduces a **Service/Content** layer. This justifies a much higher ARPU (Average Revenue Per User) and moves the app into the "Coaching" category.

---

## 4. Implementation Strategy (The "How")

### Phase 1: The "Paywall" (Now - 1 Month)
*   **Tech Stack:** **RevenueCat** (Industry standard).
*   **Implementation:**
    1.  Create `PaywallView` highlighting both Features AND Support guarantees.
    2.  Gate the "Invite Partner" button.
    3.  Gate the "Doctor Report" button.

### Phase 2: Service Integration (1-3 Months)
*   **Support Portal:** Add a "Contact Support" button in Settings.
    *   *Free:* Opens FAQ web page.
    *   *Paid:* Opens in-app Intercom/Email composer with "Priority" tag.

### Phase 3: The "Expansion" (6+ Months)
*   **Content Library:** Partner with experts to provide exclusive articles/videos for Pro users.

---

## 5. Next Steps (Execution)

1.  **Build the Value:** Implement the **Doctor Report PDF**. (You need a "Pro" feature to sell first).
2.  **Build the Gate:** Create the Paywall UI.
3.  **Build the Service:** Add the "Support" section to Settings.