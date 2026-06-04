# Release Checklist

## v0.1.0

- [x] Confirm `versionName` is `0.1.0`.
- [x] Run unit tests.
- [x] Build debug APK.
- [x] Install APK on emulator or device.
- [x] Launch app and load sample data.
- [x] Build a handoff card and confirm the share button is enabled.
- [x] Capture screenshot at `docs/screenshots/doghandoffcard-main.png`.
- [x] Commit release-ready changes.
- [x] Confirm GitHub Actions passed on `main`.
- [ ] Tag `v0.1.0`.
- [ ] Create GitHub Release with APK attached.

## Release Notes Draft

DogHandoffCard v0.1.0 is the first Android open-source prototype release.

Highlights:

- Native Android handoff form for senior-dog care details.
- Readiness scoring for missing critical handoff information.
- Local draft save and restore.
- Plain-text sharing through Android share intents.
- Unit tests and GitHub Actions build workflow.
