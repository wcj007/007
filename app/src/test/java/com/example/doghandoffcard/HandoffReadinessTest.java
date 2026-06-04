package com.example.doghandoffcard;

import org.junit.Test;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public final class HandoffReadinessTest {
    @Test
    public void flagsCriticalMissingDetails() {
        DogProfile profile = new DogProfile();
        HandoffDraft draft = new HandoffDraft();

        HandoffReadinessReport report = HandoffReadiness.evaluate(profile, draft);
        Set<String> ids = ids(report);

        assertTrue(report.hasBlockers());
        assertTrue(ids.contains("missing-dog-name"));
        assertTrue(ids.contains("missing-feeding"));
        assertTrue(ids.contains("missing-owner-phone"));
        assertTrue(report.score < 80);
    }

    @Test
    public void passesCompleteHandoffData() {
        DogProfile profile = completeProfile();
        HandoffDraft draft = new HandoffDraft();
        draft.caregiverName = "Boarding staff";

        HandoffReadinessReport report = HandoffReadiness.evaluate(profile, draft);

        assertFalse(report.hasBlockers());
        assertTrue(report.score >= 90);
        assertEquals("Ready to share", report.statusTitle());
    }

    @Test
    public void blocksInvalidCoverageWindow() {
        DogProfile profile = completeProfile();
        HandoffDraft draft = new HandoffDraft();
        draft.startAt = LocalDateTime.of(2026, 6, 5, 10, 0);
        draft.endAt = LocalDateTime.of(2026, 6, 5, 9, 0);

        HandoffReadinessReport report = HandoffReadiness.evaluate(profile, draft);

        assertTrue(report.hasBlockers());
        assertTrue(ids(report).contains("invalid-coverage-window"));
    }

    @Test
    public void buildsPlainTextCardWithMedicationAndContacts() {
        DogProfile profile = completeProfile();
        profile.temperament = "Friendly, but nervous around stairs.";
        profile.doNotDo = "Do not allow sofa jumping.";
        profile.careRule.water = "Refresh water twice daily.";
        profile.careRule.foodsToAvoid = "No chicken bones, grapes, raisins, or onions.";
        HandoffDraft draft = new HandoffDraft();
        draft.caregiverName = "Boarding staff";
        draft.caregiverType = "Boarding";
        draft.tripNote = "Owner is away overnight.";

        HandoffCardSnapshot snapshot = HandoffCardBuilder.build(profile, draft);

        assertTrue(snapshot.plainText.contains("Pimobendan"));
        assertTrue(snapshot.plainText.contains("Owner"));
        assertTrue(snapshot.plainText.contains("Friendly, but nervous around stairs."));
        assertTrue(snapshot.plainText.contains("Refresh water twice daily."));
        assertTrue(snapshot.plainText.contains("Owner is away overnight."));
        assertTrue(snapshot.plainText.contains("6. Contacts"));
    }

    @Test
    public void sortsMedicationByFirstScheduleTime() {
        DogProfile profile = completeProfile();

        MedicationItem lateMedication = new MedicationItem();
        lateMedication.name = "Evening supplement";
        lateMedication.dosage = "1 scoop";
        lateMedication.schedule = "20:30";
        lateMedication.missedDoseRule = "Skip and tell owner.";

        MedicationItem earlyMedication = new MedicationItem();
        earlyMedication.name = "Morning eye drops";
        earlyMedication.dosage = "2 drops";
        earlyMedication.schedule = "07:30";
        earlyMedication.missedDoseRule = "Call owner.";

        profile.medications.clear();
        profile.medications.add(lateMedication);
        profile.medications.add(earlyMedication);

        HandoffCardSnapshot snapshot = HandoffCardBuilder.build(profile, new HandoffDraft());

        assertTrue(snapshot.plainText.indexOf("Morning eye drops") < snapshot.plainText.indexOf("Evening supplement"));
    }

    private DogProfile completeProfile() {
        DogProfile profile = new DogProfile();
        profile.name = "Lucky";
        profile.age = "13 years";
        profile.breed = "Corgi";
        profile.weight = "12.5kg";
        profile.careRule.feeding = "Two meals, 80g each";
        profile.careRule.walks = "3 short walks a day";
        profile.careRule.callOwnerIf = "Call owner if medication is refused or vomited.";
        profile.careRule.goVetIf = "Go to a vet for seizures, breathing trouble, or collapse.";

        MedicationItem medication = new MedicationItem();
        medication.name = "Pimobendan";
        medication.dosage = "1 tablet";
        medication.schedule = "08:00,20:00";
        medication.missedDoseRule = "Call owner before making up a missed dose.";
        profile.medications.add(medication);

        EmergencyContact owner = new EmergencyContact();
        owner.role = "Owner";
        owner.name = "Test Owner";
        owner.phone = "TEST-OWNER-PHONE";
        profile.contacts.add(owner);

        EmergencyContact clinic = new EmergencyContact();
        clinic.role = "Clinic";
        clinic.name = "Test Clinic";
        clinic.phone = "TEST-CLINIC-PHONE";
        profile.contacts.add(clinic);

        return profile;
    }

    private Set<String> ids(HandoffReadinessReport report) {
        Set<String> ids = new HashSet<>();
        for (HandoffReadinessItem item : report.items) {
            ids.add(item.id);
        }
        return ids;
    }
}
