# DogHandoffCard

DogHandoffCard is a local-first SwiftUI iPhone prototype for creating senior-dog
care handoff cards before family care, boarding, or temporary pet sitting.

The app focuses on one practical workflow: collect the dog profile, medication
rules, emergency contacts, and trip details, then export a caregiver-ready
handoff card as image, PDF, or plain text.

## Current Features

- Single-dog profile with age, breed, weight, temperament, and no-go tags
- Medication schedule entries with dose, timing, food rules, and missed-dose notes
- Daily care rules for feeding, water, walks, trigger warnings, and vet guidance
- Owner, backup, clinic, and boarding contacts
- Handoff readiness scoring that flags missing critical details before sharing
- Saved handoff card history with duplicate-and-edit support
- Image, PDF, and plain-text export

## Structure

- `DogHandoffCard.xcodeproj`: Xcode project
- `DogHandoffCard/`: app source
- `DogHandoffCardTests/`: unit tests

## Open On Mac

1. Open `DogHandoffCard.xcodeproj` in Xcode 16 or later.
2. Select an iPhone simulator or device.
3. Build and run.

## Verification

The repository includes unit tests for the handoff card builder and readiness
scoring logic. Run them from Xcode with the `DogHandoffCardTests` target.

This project is currently maintained as an early-stage open prototype. It has
not been packaged for App Store distribution.
