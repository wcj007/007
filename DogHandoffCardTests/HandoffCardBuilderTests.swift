import XCTest
@testable import DogHandoffCard

final class HandoffCardBuilderTests: XCTestCase {
    func testMedicationSectionIncludesThreeSortedEntries() {
        let pet = PetProfile(
            name: "Lucky",
            ageText: "13 years",
            breed: "Corgi",
            weightText: "12.5kg",
            sex: "Male",
            neuterStatus: "Neutered",
            chipID: "123456",
            temperamentTagsText: "friendly,food guarding",
            tabooTagsText: "no chicken bones"
        )

        let careRule = CareRule(
            feedingAmount: "Two meals, 80g each",
            waterNotes: "Fresh water all day",
            walkFrequency: "3 walks a day",
            forbiddenFoodsText: "chocolate,onion",
            cannotDoText: "do not give unfamiliar treats",
            triggerWarningsText: "energy drop,vomits medication",
            callOwnerNowText: "Call the owner for missed doses, vomiting, or refusal to eat",
            goVetNowText: "Go to the vet for seizures, ongoing vomiting, or breathing trouble",
            handoffTipsText: "Gets nervous around unfamiliar dogs"
        )
        careRule.pet = pet
        pet.careRules.append(careRule)

        let owner = EmergencyContact(role: "Owner", name: "Test Owner", phone: "TEST-CONTACT", address: "Example District", note: "")
        owner.pet = pet
        pet.contacts.append(owner)

        let medA = MedicationItem(
            name: "Pimobendan",
            form: "Tablet",
            dosage: "1 tablet",
            frequencyText: "Twice daily",
            specificTimes: "20:00,08:00",
            withFood: true,
            needsSplitting: true,
            hideInFood: false,
            missedDoseInstruction: "Call the owner before deciding whether to make up a missed dose",
            notes: "Give in the morning and evening"
        )
        medA.pet = pet

        let medB = MedicationItem(
            name: "Liver Support",
            form: "Tablet",
            dosage: "Half tablet",
            frequencyText: "Once daily",
            specificTimes: "13:00",
            withFood: false,
            needsSplitting: true,
            hideInFood: true,
            missedDoseInstruction: "Do not double the next dose",
            notes: ""
        )
        medB.pet = pet

        let medC = MedicationItem(
            name: "Probiotic",
            form: "Powder",
            dosage: "1 pack",
            frequencyText: "Once daily",
            specificTimes: "09:00",
            withFood: true,
            needsSplitting: false,
            hideInFood: true,
            missedDoseInstruction: "",
            notes: "Mix with breakfast"
        )
        medC.pet = pet

        pet.medications = [medA, medB, medC]

        let draft = HandoffCardDraft(
            title: "Holiday Boarding Card",
            caregiverName: "Test Boarding Staff",
            caregiverType: "Boarding",
            customNote: "Back home on the afternoon of May 2",
            version: 3
        )

        let snapshot = HandoffCardBuilder.build(for: pet, draft: draft)

        XCTAssertTrue(snapshot.medicationSection.contains("Pimobendan"))
        XCTAssertTrue(snapshot.medicationSection.contains("Liver Support"))
        XCTAssertTrue(snapshot.medicationSection.contains("Probiotic"))
        XCTAssertTrue(snapshot.medicationSection.contains("Split tablet: Yes"))
        XCTAssertTrue(snapshot.plainText.contains("6. Contacts"))

        let firstIndex = snapshot.medicationSection.range(of: "08:00 / 20:00")?.lowerBound
        let secondIndex = snapshot.medicationSection.range(of: "09:00")?.lowerBound
        let thirdIndex = snapshot.medicationSection.range(of: "13:00")?.lowerBound

        XCTAssertNotNil(firstIndex)
        XCTAssertNotNil(secondIndex)
        XCTAssertNotNil(thirdIndex)
    }

    func testDuplicatingRecordIncrementsVersion() {
        let record = HandoffCardRecord(
            title: "Spring Festival Handoff",
            caregiverName: "Family Caregiver",
            caregiverType: "Family",
            startDate: .now,
            endDate: .now,
            customNote: "Back before 9pm",
            version: 2,
            whoSection: "Lucky",
            mustDoSection: "Give medication",
            medicationSection: "1. Pimobendan",
            callOwnerSection: "Call the owner if the dog spits out medication",
            goVetSection: "Go to the vet for seizures",
            contactSection: "Owner: TEST-CONTACT",
            plainText: "plain"
        )

        let duplicated = HandoffCardDraft(duplicating: record)

        XCTAssertEqual(duplicated.version, 3)
        XCTAssertEqual(duplicated.title, record.title)
        XCTAssertEqual(duplicated.caregiverName, record.caregiverName)
        XCTAssertEqual(duplicated.caregiverType, record.caregiverType)
        XCTAssertEqual(duplicated.customNote, record.customNote)
    }

    func testReadinessReportFlagsCriticalMissingDetails() {
        let pet = PetProfile()

        let report = HandoffReadiness.evaluate(for: pet)
        let ids = Set(report.items.map(\.id))

        XCTAssertTrue(report.hasBlockers)
        XCTAssertTrue(ids.contains("missing-dog-name"))
        XCTAssertTrue(ids.contains("missing-care-rules"))
        XCTAssertTrue(ids.contains("missing-owner-phone"))
        XCTAssertLessThan(report.score, 80)
    }

    func testReadinessReportPassesCompleteHandoffData() {
        let pet = PetProfile(
            name: "Lucky",
            ageText: "13 years",
            breed: "Corgi",
            weightText: "12.5kg"
        )

        let careRule = CareRule(
            feedingAmount: "Two meals, 80g each",
            waterNotes: "Fresh water all day",
            walkFrequency: "3 walks a day",
            forbiddenFoodsText: "chocolate,onion",
            cannotDoText: "do not give unfamiliar treats",
            triggerWarningsText: "energy drop,vomits medication",
            callOwnerNowText: "Call the owner for missed doses, vomiting, or refusal to eat",
            goVetNowText: "Go to the vet for seizures, ongoing vomiting, or breathing trouble",
            handoffTipsText: "Gets nervous around unfamiliar dogs"
        )
        careRule.pet = pet
        pet.careRules.append(careRule)

        let owner = EmergencyContact(role: "Owner", name: "Test Owner", phone: "TEST-CONTACT")
        owner.pet = pet
        pet.contacts.append(owner)

        let clinic = EmergencyContact(role: "Clinic", name: "Test Clinic", phone: "TEST-CLINIC")
        clinic.pet = pet
        pet.contacts.append(clinic)

        let medication = MedicationItem(
            name: "Pimobendan",
            dosage: "1 tablet",
            frequencyText: "Twice daily",
            specificTimes: "08:00,20:00",
            missedDoseInstruction: "Call the owner before making up a missed dose"
        )
        medication.pet = pet
        pet.medications.append(medication)

        let draft = HandoffCardDraft(caregiverName: "Test Boarding Staff")
        let report = HandoffReadiness.evaluate(for: pet, draft: draft)

        XCTAssertFalse(report.hasBlockers)
        XCTAssertGreaterThanOrEqual(report.score, 90)
        XCTAssertEqual(report.statusTitle, "Ready to share")
    }

    func testReadinessReportBlocksInvalidCoverageWindow() {
        let startDate = Date(timeIntervalSince1970: 100)
        let endDate = Date(timeIntervalSince1970: 50)
        let draft = HandoffCardDraft(startDate: startDate, endDate: endDate)
        let pet = PetProfile(name: "Lucky")

        let report = HandoffReadiness.evaluate(for: pet, draft: draft)
        let ids = Set(report.items.map(\.id))

        XCTAssertTrue(report.hasBlockers)
        XCTAssertTrue(ids.contains("invalid-coverage-window"))
    }
}
