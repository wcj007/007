package com.example.doghandoffcard;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

final class DogProfile {
    String name = "";
    String age = "";
    String breed = "";
    String weight = "";
    String temperament = "";
    String doNotDo = "";
    CareRule careRule = new CareRule();
    final List<MedicationItem> medications = new ArrayList<>();
    final List<EmergencyContact> contacts = new ArrayList<>();

    List<MedicationItem> sortedMedications() {
        List<MedicationItem> sorted = new ArrayList<>(medications);
        sorted.sort(Comparator.comparing(MedicationItem::primarySortKey));
        return sorted;
    }

    List<EmergencyContact> sortedContacts() {
        List<EmergencyContact> sorted = new ArrayList<>(contacts);
        sorted.sort(
            Comparator
                .comparingInt(EmergencyContact::roleRank)
                .thenComparing(contact -> contact.name)
        );
        return sorted;
    }
}

final class MedicationItem {
    String name = "";
    String dosage = "";
    String schedule = "";
    String withFood = "";
    String missedDoseRule = "";
    String notes = "";

    String primarySortKey() {
        String firstTime = schedule.trim().split(",", 2)[0].trim();
        return firstTime.isEmpty() ? "99:99" : firstTime;
    }
}

final class CareRule {
    String feeding = "";
    String water = "";
    String walks = "";
    String foodsToAvoid = "";
    String callOwnerIf = "";
    String goVetIf = "";
    String handoffNotes = "";
}

final class EmergencyContact {
    String role = "Owner";
    String name = "";
    String phone = "";
    String address = "";
    String note = "";

    int roleRank() {
        switch (role) {
            case "Owner":
                return 0;
            case "Backup":
                return 1;
            case "Clinic":
                return 2;
            case "Boarding":
                return 3;
            default:
                return 9;
        }
    }
}

final class HandoffDraft {
    String title = "Care Handoff Card";
    String caregiverName = "";
    String caregiverType = "Family / Boarding";
    LocalDateTime startAt = LocalDateTime.now();
    LocalDateTime endAt = LocalDateTime.now().plusDays(1);
    String tripNote = "";
}

final class HandoffCardSnapshot {
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    final String title;
    final String subtitle;
    final LocalDateTime generatedAt;
    final String plainText;

    HandoffCardSnapshot(String title, String subtitle, LocalDateTime generatedAt, String plainText) {
        this.title = title;
        this.subtitle = subtitle;
        this.generatedAt = generatedAt;
        this.plainText = plainText;
    }

    String generatedAtText() {
        return FORMATTER.format(generatedAt);
    }

    static String formatDateTime(LocalDateTime value) {
        return FORMATTER.format(value);
    }
}
