package com.example.doghandoffcard;

import java.time.LocalDateTime;

public final class HandoffCardBuilder {
    private HandoffCardBuilder() {
    }

    static HandoffCardSnapshot build(DogProfile profile, HandoffDraft draft) {
        String title = HandoffReadiness.fallback(draft.title, "Care Handoff Card");
        String subtitle = HandoffReadiness.fallback(draft.caregiverType, "Caregiver")
            + " | "
            + HandoffReadiness.fallback(draft.caregiverName, "TBD");

        StringBuilder builder = new StringBuilder();
        builder.append(title).append('\n');
        builder.append(subtitle).append('\n');
        builder.append("Generated: ").append(HandoffCardSnapshot.formatDateTime(LocalDateTime.now())).append("\n\n");

        builder.append("1. Dog Profile\n");
        builder.append("Name: ").append(HandoffReadiness.fallback(profile.name, "Not set")).append('\n');
        builder.append("Age: ").append(HandoffReadiness.fallback(profile.age, "Not set")).append('\n');
        builder.append("Breed: ").append(HandoffReadiness.fallback(profile.breed, "Not set")).append('\n');
        builder.append("Weight: ").append(HandoffReadiness.fallback(profile.weight, "Not set")).append('\n');
        builder.append("Temperament: ").append(HandoffReadiness.fallback(profile.temperament, "Not set")).append('\n');
        builder.append("Do not do: ").append(HandoffReadiness.fallback(profile.doNotDo, "Not set")).append("\n\n");

        builder.append("2. Must Do Today\n");
        builder.append("Caregiver: ").append(subtitle).append('\n');
        builder.append("Coverage: ")
            .append(HandoffCardSnapshot.formatDateTime(draft.startAt))
            .append(" - ")
            .append(HandoffCardSnapshot.formatDateTime(draft.endAt))
            .append('\n');
        builder.append("Feeding: ").append(HandoffReadiness.fallback(profile.careRule.feeding, "Follow normal routine")).append('\n');
        builder.append("Water: ").append(HandoffReadiness.fallback(profile.careRule.water, "Keep clean water available")).append('\n');
        builder.append("Walks: ").append(HandoffReadiness.fallback(profile.careRule.walks, "Follow normal routine")).append('\n');
        builder.append("Foods to avoid: ").append(HandoffReadiness.fallback(profile.careRule.foodsToAvoid, "Not set")).append('\n');
        builder.append("Trip note: ").append(HandoffReadiness.fallback(draft.tripNote, "None")).append("\n\n");

        builder.append("3. Medication Instructions\n");
        if (profile.sortedMedications().isEmpty()) {
            builder.append("No medications have been added. Confirm this is intentional.\n\n");
        } else {
            int index = 1;
            for (MedicationItem medication : profile.sortedMedications()) {
                builder.append(index++).append(". ").append(HandoffReadiness.fallback(medication.name, "Unnamed medication")).append('\n');
                builder.append("Time: ").append(HandoffReadiness.fallback(medication.schedule, "Not set")).append('\n');
                builder.append("Dose: ").append(HandoffReadiness.fallback(medication.dosage, "Not set")).append('\n');
                builder.append("With food: ").append(HandoffReadiness.fallback(medication.withFood, "Not set")).append('\n');
                builder.append("Missed dose: ").append(HandoffReadiness.fallback(medication.missedDoseRule, "Call owner before deciding")).append('\n');
                if (!HandoffReadiness.isBlank(medication.notes)) {
                    builder.append("Notes: ").append(medication.notes.trim()).append('\n');
                }
                builder.append('\n');
            }
        }

        builder.append("4. Call Owner Immediately If\n");
        builder.append(HandoffReadiness.fallback(
            profile.careRule.callOwnerIf,
            "Energy drops, medication is refused or vomited, appetite changes, diarrhea starts, or anything feels uncertain."
        )).append("\n\n");

        builder.append("5. Go To Vet Immediately If\n");
        builder.append(HandoffReadiness.fallback(
            profile.careRule.goVetIf,
            "Breathing trouble, seizures, collapse, suspected poisoning, ongoing vomiting, or bleeding."
        )).append("\n\n");

        builder.append("6. Contacts\n");
        if (profile.sortedContacts().isEmpty()) {
            builder.append("No contacts have been added.\n");
        } else {
            for (EmergencyContact contact : profile.sortedContacts()) {
                builder.append(contact.role).append(": ").append(HandoffReadiness.fallback(contact.name, "Not set")).append('\n');
                builder.append("Phone: ").append(HandoffReadiness.fallback(contact.phone, "Not set")).append('\n');
                if (!HandoffReadiness.isBlank(contact.address)) {
                    builder.append("Address: ").append(contact.address.trim()).append('\n');
                }
                if (!HandoffReadiness.isBlank(contact.note)) {
                    builder.append("Note: ").append(contact.note.trim()).append('\n');
                }
                builder.append('\n');
            }
        }

        return new HandoffCardSnapshot(title, subtitle, LocalDateTime.now(), builder.toString().trim());
    }
}
