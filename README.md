# DogHandoffCard

DogHandoffCard is a small native Android prototype for creating senior-dog care
handoff cards before family care, boarding, or temporary pet sitting.

The app focuses on one practical Android workflow: enter the dog's care details,
check whether the handoff is safe to share, and generate a plain-text card that
can be sent through any Android share target.

## Current Features

- Native Android app module using Java and Gradle
- Single-dog handoff form for dog profile, feeding, walks, medication, owner,
  clinic, and caregiver details
- Handoff readiness scoring that flags missing critical details before sharing
- Share button that is disabled until critical blockers are fixed
- Plain-text handoff card builder for SMS, WeChat, email, notes, or any Android
  share target
- Unit tests for readiness scoring and card generation logic

## Project Structure

- `settings.gradle.kts`: Gradle project settings
- `build.gradle.kts`: top-level Android Gradle plugin declaration
- `app/build.gradle.kts`: Android app module configuration
- `app/src/main/java/com/example/doghandoffcard/`: app and domain logic
- `app/src/test/java/com/example/doghandoffcard/`: unit tests

## Open On Android Studio

1. Install Android Studio with Android SDK 35 or newer.
2. Open this repository folder in Android Studio.
3. Let Gradle sync.
4. Run the `app` configuration on an emulator or Android phone.

## Verification

Run unit tests from Android Studio, or use:

```powershell
gradle test
```

If you prefer the Android Studio workflow, open the project and run the `test`
task from the Gradle tool window.

## Known Limits

- Early local prototype; no cloud sync, account system, or database yet.
- The current UI is a simple single-screen Android form.
- Export is plain text through Android share intents; PDF/image export is not
  implemented in this Android version.
