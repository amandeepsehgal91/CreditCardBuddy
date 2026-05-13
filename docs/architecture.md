# Credit Card Buddy Architecture

## Goal

Build a consumer-facing credit card management app that starts in India and can expand to the US. The app should centralize credit cards, spend data, rewards, and partner integrations.

## App architecture

### Mobile layer

- **SwiftUI** for UI
- **MVVM** for presentation logic
- **ObservableObject** view models
- **Async/Await + Combine** for asynchronous data flows
- **Keychain** for secure token storage
- **Core Data / SQLite** for local cache of card metadata and transaction snapshots

### Backend layer

- **Node.js + TypeScript** for API services
- **Express** or **Fastify** for REST endpoints
- **PostgreSQL** for card, transaction, reward, and user data
- **JWT** or opaque session tokens for mobile authentication
- **Integration adapters** for Account Aggregator providers

### Integration layer

- **Adapter pattern** for each data provider
- Standard internal API shape for card accounts, transactions, and rewards
- Providers to support:
  - OneMoney (AA)
  - Finvu (AA)
  - Perfios (statement parsing)
  - Future US provider: Plaid / MX

## Core entities

- `User`
- `CreditCard`
- `CardAccount`
- `Transaction`
- `RewardBalance`
- `Recommendation`
- `ProviderConsent`

## MVP screens

1. **Home Dashboard**
   - Total cards
   - Monthly spend
   - Active cards
   - Rewards snapshot
   - Quick actions: connect card, view spend, recommendation

2. **Card Portfolio**
   - List of connected cards
   - Current balance / dues
   - Reward program type

3. **Spend Summary**
   - Category breakdown
   - Best card recommendations by category
   - Reward rate comparisons

4. **Connect Card**
   - Consent flow to AA provider
   - Bank/card selection
   - Connect status

5. **Settings / Partners**
   - Profile
   - Connected providers
   - Data refresh
   - Security

## First screen: Home Dashboard

The first screen should be a single-pane dashboard with:

- **Header**: app name, notification icon
- **Card snapshot**: total connected cards, monthly spend
- **Rewards summary**: points across programs, best upcoming redemption
- **Actions**: Connect a new card, view spend, get recommendations
- **Recent activity**: last synced cards, last update time

## Scaling to the US market

- Keep business logic in backend, not mobile UI
- Create a provider abstraction for each market
- Separate reward rules by region
- Keep UI currency- and locale-aware
