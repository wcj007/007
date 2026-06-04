package com.example.doghandoffcard;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public final class HandoffReadiness {
    private HandoffReadiness() {
    }

    static HandoffReadinessReport evaluate(DogProfile profile, HandoffDraft draft) {
        List<HandoffReadinessItem> items = new ArrayList<>();

        if (isBlank(profile.name)) {
            items.add(HandoffReadinessItem.blocker(
                "missing-dog-name",
                "Add the dog name",
                "The caregiver needs a clear dog name on the card."
            ));
        }

        if (isBlank(profile.age) && isBlank(profile.breed)) {
            items.add(HandoffReadinessItem.warning(
                "missing-profile-context",
                "Add age or breed",
                "Age or breed helps caregivers identify the dog and understand senior-care context."
            ));
        }

        evaluateCareRules(profile.careRule, items);
        evaluateMedications(profile.sortedMedications(), items);
        evaluateContacts(profile.sortedContacts(), items);
        evaluateDraft(draft, items);

        int blockers = 0;
        int warnings = 0;
        for (HandoffReadinessItem item : items) {
            if (item.severity == HandoffReadinessSeverity.BLOCKER) {
                blockers++;
            } else if (item.severity == HandoffReadinessSeverity.WARNING) {
                warnings++;
            }
        }

        int score = Math.max(0, Math.min(100, 100 - blockers * 18 - warnings * 8));
        return new HandoffReadinessReport(score, items);
    }

    private static void evaluateCareRules(CareRule rule, List<HandoffReadinessItem> items) {
        if (isBlank(rule.feeding)) {
            items.add(HandoffReadinessItem.blocker(
                "missing-feeding",
                "Add feeding instructions",
                "A caregiver should not need to guess meal amount or frequency."
            ));
        }

        if (isBlank(rule.walks)) {
            items.add(HandoffReadinessItem.warning(
                "missing-walks",
                "Add walk frequency",
                "Walk timing keeps the day predictable for a senior dog."
            ));
        }

        if (isBlank(rule.callOwnerIf)) {
            items.add(HandoffReadinessItem.warning(
                "missing-call-owner",
                "Add call-owner triggers",
                "List the signs that should make the caregiver call you immediately."
            ));
        }

        if (isBlank(rule.goVetIf)) {
            items.add(HandoffReadinessItem.warning(
                "missing-vet-guidance",
                "Add emergency vet guidance",
                "The handoff should say when to go directly to a vet."
            ));
        }
    }

    private static void evaluateMedications(List<MedicationItem> medications, List<HandoffReadinessItem> items) {
        if (medications.isEmpty()) {
            items.add(HandoffReadinessItem.info(
                "no-medications",
                "Confirm medication status",
                "If the dog takes no medication, leave this as a conscious empty state."
            ));
            return;
        }

        for (MedicationItem medication : medications) {
            String displayName = fallback(medication.name, "Unnamed medication");

            if (isBlank(medication.name)) {
                items.add(HandoffReadinessItem.blocker(
                    "missing-medication-name",
                    "Name every medication",
                    "One medication entry is missing its name."
                ));
            }

            if (isBlank(medication.dosage)) {
                items.add(HandoffReadinessItem.blocker(
                    "missing-dose-" + safeId(displayName),
                    "Add dose for " + displayName,
                    "Dose must be explicit before a temporary caregiver gives medication."
                ));
            }

            if (isBlank(medication.schedule)) {
                items.add(HandoffReadinessItem.blocker(
                    "missing-schedule-" + safeId(displayName),
                    "Add timing for " + displayName,
                    "Use exact times or a clear frequency such as twice daily."
                ));
            }

            if (isBlank(medication.missedDoseRule)) {
                items.add(HandoffReadinessItem.warning(
                    "missing-missed-dose-" + safeId(displayName),
                    "Add missed-dose rule for " + displayName,
                    "This avoids double-dosing or unsafe make-up doses."
                ));
            }
        }
    }

    private static void evaluateContacts(List<EmergencyContact> contacts, List<HandoffReadinessItem> items) {
        EmergencyContact owner = findContact(contacts, "Owner");
        if (owner == null || isBlank(owner.phone)) {
            items.add(HandoffReadinessItem.blocker(
                "missing-owner-phone",
                "Add owner phone",
                "The exported card needs an owner contact that works outside the app."
            ));
        }

        EmergencyContact clinic = findContact(contacts, "Clinic");
        if (clinic == null || isBlank(clinic.phone)) {
            items.add(HandoffReadinessItem.warning(
                "missing-clinic-phone",
                "Add clinic phone",
                "A vet or clinic phone should be available in emergencies."
            ));
        }
    }

    private static void evaluateDraft(HandoffDraft draft, List<HandoffReadinessItem> items) {
        if (isBlank(draft.caregiverName)) {
            items.add(HandoffReadinessItem.warning(
                "missing-caregiver-name",
                "Add caregiver name",
                "Naming the recipient makes reused cards less ambiguous."
            ));
        }

        if (draft.endAt.isBefore(draft.startAt)) {
            items.add(HandoffReadinessItem.blocker(
                "invalid-coverage-window",
                "Fix coverage dates",
                "End time should be after the start time."
            ));
        }
    }

    private static EmergencyContact findContact(List<EmergencyContact> contacts, String role) {
        for (EmergencyContact contact : contacts) {
            if (role.equals(contact.role)) {
                return contact;
            }
        }
        return null;
    }

    static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    static String fallback(String value, String fallback) {
        return isBlank(value) ? fallback : value.trim();
    }

    private static String safeId(String value) {
        return value.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
    }
}

enum HandoffReadinessSeverity {
    BLOCKER,
    WARNING,
    INFO
}

final class HandoffReadinessItem {
    final String id;
    final String title;
    final String detail;
    final HandoffReadinessSeverity severity;

    private HandoffReadinessItem(String id, String title, String detail, HandoffReadinessSeverity severity) {
        this.id = id;
        this.title = title;
        this.detail = detail;
        this.severity = severity;
    }

    static HandoffReadinessItem blocker(String id, String title, String detail) {
        return new HandoffReadinessItem(id, title, detail, HandoffReadinessSeverity.BLOCKER);
    }

    static HandoffReadinessItem warning(String id, String title, String detail) {
        return new HandoffReadinessItem(id, title, detail, HandoffReadinessSeverity.WARNING);
    }

    static HandoffReadinessItem info(String id, String title, String detail) {
        return new HandoffReadinessItem(id, title, detail, HandoffReadinessSeverity.INFO);
    }
}

final class HandoffReadinessReport {
    final int score;
    final List<HandoffReadinessItem> items;

    HandoffReadinessReport(int score, List<HandoffReadinessItem> items) {
        this.score = score;
        this.items = new ArrayList<>(items);
    }

    boolean hasBlockers() {
        for (HandoffReadinessItem item : items) {
            if (item.severity == HandoffReadinessSeverity.BLOCKER) {
                return true;
            }
        }
        return false;
    }

    String statusTitle() {
        if (hasBlockers()) {
            return "Needs critical details";
        }
        if (score >= 90) {
            return "Ready to share";
        }
        if (score >= 75) {
            return "Usable with notes";
        }
        return "Needs review";
    }

    String statusDescription() {
        if (hasBlockers()) {
            return "Add the critical items before sending this handoff card.";
        }
        for (HandoffReadinessItem item : items) {
            if (item.severity == HandoffReadinessSeverity.WARNING) {
                return "The card can be shared, but a few optional details would make it safer.";
            }
        }
        return "The card includes the core details a temporary caregiver needs.";
    }

    List<HandoffReadinessItem> priorityItems() {
        List<HandoffReadinessItem> sorted = new ArrayList<>(items);
        sorted.sort(Comparator.comparingInt(item -> severityRank(item.severity)));
        return sorted;
    }

    private int severityRank(HandoffReadinessSeverity severity) {
        switch (severity) {
            case BLOCKER:
                return 0;
            case WARNING:
                return 1;
            case INFO:
            default:
                return 2;
        }
    }
}
