# Security

DogHandoffCard is an offline Android prototype. It does not currently sync data
to a server or require an account.

## Reporting

Please open a GitHub issue for non-sensitive security or privacy problems.

Do not post real owner phone numbers, clinic contacts, medication schedules, or
private pet-care details in public issues. Use fake sample data that preserves
the shape of the problem.

## Current Data Model

- Drafts are stored locally on the device with Android `SharedPreferences`.
- Export uses Android share intents.
- No remote API, analytics service, or cloud database is used.
