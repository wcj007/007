# Contributing

Thanks for helping improve DogHandoffCard. This project is intentionally small:
changes should make senior-dog care handoffs clearer, safer, or easier to test.

## Good First Contributions

- Improve the handoff card wording.
- Add readiness checks for common senior-dog care risks.
- Add unit tests around card generation and validation.
- Improve Android accessibility, spacing, and input labels.
- Report real caregiver handoff scenarios that the app does not handle well.

## Local Checks

Before opening a pull request, run the unit tests and debug build:

```powershell
.\gradlew.bat test
.\gradlew.bat assembleDebug
```

## Pull Request Expectations

- Keep changes focused.
- Explain the care scenario or bug being addressed.
- Add or update tests when domain logic changes.
- Do not include real phone numbers, private medical data, or personal contact
  details in screenshots, issues, tests, or examples.

## Privacy Rule

Use fake sample data in public artifacts. DogHandoffCard is a care-handoff tool,
but the repository should not store real owner, clinic, medication, or pet data.
