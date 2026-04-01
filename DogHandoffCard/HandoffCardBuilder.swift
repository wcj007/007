import Foundation

enum HandoffCardBuilder {
    static func build(for pet: PetProfile, draft: HandoffCardDraft) -> HandoffCardSnapshot {
        let title = draft.title.ifBlank("Care Handoff Card")
        let subtitle = "\(draft.caregiverType.ifBlank("Caregiver")) | \(draft.caregiverName.ifBlank("TBD")) | v\(draft.version)"

        let who = buildWhoSection(for: pet)
        let mustDo = buildMustDoSection(for: pet, draft: draft)
        let medication = buildMedicationSection(for: pet)
        let callOwner = buildCallOwnerSection(for: pet)
        let goVet = buildGoVetSection(for: pet)
        let contacts = buildContactSection(for: pet)

        let plainText = """
        \(title)
        \(subtitle)
        Generated: \(DateFormatter.handoffDate.string(from: .now))

        1. Dog Profile
        \(who)

        2. Must Do Today
        \(mustDo)

        3. Medication Instructions
        \(medication)

        4. Call Owner Immediately If
        \(callOwner)

        5. Go To Vet Immediately If
        \(goVet)

        6. Contacts
        \(contacts)
        """

        return HandoffCardSnapshot(
            title: title,
            subtitle: subtitle,
            generatedAt: .now,
            whoSection: who,
            mustDoSection: mustDo,
            medicationSection: medication,
            callOwnerSection: callOwner,
            goVetSection: goVet,
            contactSection: contacts,
            plainText: plainText
        )
    }

    static func makeRecord(for pet: PetProfile, draft: HandoffCardDraft, snapshot: HandoffCardSnapshot) -> HandoffCardRecord {
        let record = HandoffCardRecord(
            title: snapshot.title,
            caregiverName: draft.caregiverName,
            caregiverType: draft.caregiverType,
            startDate: draft.startDate,
            endDate: draft.endDate,
            customNote: draft.customNote,
            version: draft.version,
            generatedAt: snapshot.generatedAt,
            whoSection: snapshot.whoSection,
            mustDoSection: snapshot.mustDoSection,
            medicationSection: snapshot.medicationSection,
            callOwnerSection: snapshot.callOwnerSection,
            goVetSection: snapshot.goVetSection,
            contactSection: snapshot.contactSection,
            plainText: snapshot.plainText
        )
        record.pet = pet
        return record
    }

    private static func buildWhoSection(for pet: PetProfile) -> String {
        [
            "Name: \(pet.name.ifBlank("Not set"))",
            "Age: \(pet.ageText.ifBlank("Not set"))",
            "Breed: \(pet.breed.ifBlank("Not set"))",
            "Weight: \(pet.weightText.ifBlank("Not set"))",
            "Sex: \(pet.sex.ifBlank("Not set"))",
            "Neuter status: \(pet.neuterStatus.ifBlank("Not set"))",
            "Chip ID: \(pet.chipID.ifBlank("Not set"))",
            "Temperament tags: \(pet.temperamentTagsText.ifBlank("Not set"))",
            "Do-not-do tags: \(pet.tabooTagsText.ifBlank("Not set"))"
        ]
        .joined(separator: "\n")
    }

    private static func buildMustDoSection(for pet: PetProfile, draft: HandoffCardDraft) -> String {
        let careRule = pet.primaryCareRule
        var lines = [
            "Caregiver: \(draft.caregiverType.ifBlank("Caregiver")) \(draft.caregiverName.ifBlank("TBD"))",
            "Coverage: \(DateFormatter.handoffDate.string(from: draft.startDate)) - \(DateFormatter.handoffDate.string(from: draft.endDate))"
        ]

        if let careRule {
            lines.append("Feeding: \(careRule.feedingAmount.ifBlank("Follow the normal routine"))")
            lines.append("Water: \(careRule.waterNotes.ifBlank("Keep clean water available"))")
            lines.append("Walks: \(careRule.walkFrequency.ifBlank("Follow the normal routine"))")
            lines.append("Do not: \(careRule.cannotDoText.ifBlank("Not set"))")

            if !careRule.forbiddenFoodsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("Foods to avoid: \(careRule.forbiddenFoodsText)")
            }

            if !careRule.handoffTipsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("Handoff notes: \(careRule.handoffTipsText)")
            }
        }

        if !draft.customNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("This trip note: \(draft.customNote)")
        }

        return lines.joined(separator: "\n")
    }

    private static func buildMedicationSection(for pet: PetProfile) -> String {
        guard !pet.sortedMedications.isEmpty else {
            return "No medications have been added yet."
        }

        let blocks = pet.sortedMedications.enumerated().map { index, medication in
            var lines = [
                "\(index + 1). \(medication.name.ifBlank("Unnamed medication"))",
                "Time: \(medication.timeSlots.isEmpty ? medication.frequencyText.ifBlank("Not set") : medication.timeSlots.joined(separator: " / "))",
                "Dose: \(medication.dosage.ifBlank("Not set"))",
                "Form: \(medication.form.ifBlank("Not set"))",
                "How to give: \(medication.withFood ? "With food" : "Can be given alone")",
                "Split tablet: \(medication.needsSplitting ? "Yes" : "No")",
                "Hide in food: \(medication.hideInFood ? "Yes" : "No")"
            ]

            if !medication.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("Notes: \(medication.notes)")
            }

            if !medication.missedDoseInstruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("Missed dose: \(medication.missedDoseInstruction)")
            }

            if let endDate = medication.endDate {
                lines.append("Window: \(DateFormatter.shortDateOnly.string(from: medication.startDate)) - \(DateFormatter.shortDateOnly.string(from: endDate))")
            }

            return lines.joined(separator: "\n")
        }

        return blocks.joined(separator: "\n\n")
    }

    private static func buildCallOwnerSection(for pet: PetProfile) -> String {
        let careRule = pet.primaryCareRule
        var lines: [String] = []

        if let text = careRule?.callOwnerNowText, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("Call owner now: \(text)")
        }

        if let text = careRule?.triggerWarningsText, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("Watch closely: \(text)")
        }

        if lines.isEmpty {
            lines.append("If energy drops, the dog vomits medication, refuses food, has diarrhea, breathes oddly, or you are unsure about a dose, call the owner immediately.")
        }

        return lines.joined(separator: "\n")
    }

    private static func buildGoVetSection(for pet: PetProfile) -> String {
        let careRule = pet.primaryCareRule

        if let text = careRule?.goVetNowText, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return text
        }

        return "If there is ongoing vomiting, clear breathing trouble, seizures, trouble standing, confusion, suspected poisoning, or bleeding, go to the vet immediately and contact the owner."
    }

    private static func buildContactSection(for pet: PetProfile) -> String {
        guard !pet.sortedContacts.isEmpty else {
            return "No contacts have been added yet."
        }

        return pet.sortedContacts.map { contact in
            var lines = [
                "\(contact.role.ifBlank("Contact")): \(contact.name.ifBlank("Not set"))",
                "Phone: \(contact.phone.ifBlank("Not set"))"
            ]

            if !contact.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("Address: \(contact.address)")
            }

            if !contact.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("Notes: \(contact.note)")
            }

            return lines.joined(separator: "\n")
        }
        .joined(separator: "\n\n")
    }
}
