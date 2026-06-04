# DogHandoffCard

`DogHandoffCard` is an iPhone-only SwiftUI app prototype for the China market.
It helps owners of senior dogs prepare a clear handoff card before family care,
boarding, or temporary pet sitting.

Current implementation includes:
- Single-dog profile management
- Medication and care rule entry
- Emergency contact entry
- Handoff readiness scoring for missing critical details
- Handoff card preview
- Image, PDF, and plain-text export
- Handoff history duplication
- Basic unit test coverage

## Project Structure

- `DogHandoffCard.xcodeproj`: Xcode project
- `DogHandoffCard/`: app source files
- `DogHandoffCardTests/`: unit tests

## Open On Mac

1. Copy the full project folder to a macOS machine.
2. Open `DogHandoffCard.xcodeproj` with Xcode 16 or later.
3. Select an iPhone simulator or device.
4. Build and run.

## Known Limits

- This project was created on Windows, so it has not been compiled with Xcode yet.
- The first version is local-first with no account system, cloud sync, or push notifications.
- PDF export is optimized for information completeness, not for fixed A4 pagination.

## Handoff Readiness Rules

The readiness check is intentionally simple and caregiver-focused. It blocks
sharing when critical information is missing, such as dog name, feeding
instructions, medication dose/timing, owner phone, or a valid handoff window.
It also shows warnings for useful but less critical details, such as clinic
phone, walk frequency, missed-dose instructions, and explicit vet guidance.
