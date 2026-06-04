import Foundation

enum HandoffReadinessSeverity: String {
    case blocker
    case warning
    case info
}

struct HandoffReadinessItem: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let severity: HandoffReadinessSeverity
}

struct HandoffReadinessReport: Hashable {
    let score: Int
    let items: [HandoffReadinessItem]

    var blockers: [HandoffReadinessItem] {
        items.filter { $0.severity == .blocker }
    }

    var warnings: [HandoffReadinessItem] {
        items.filter { $0.severity == .warning }
    }

    var hasBlockers: Bool {
        !blockers.isEmpty
    }

    var statusTitle: String {
        if hasBlockers {
            return "Needs critical details"
        }
        if score >= 90 {
            return "Ready to share"
        }
        if score >= 75 {
            return "Usable with notes"
        }
        return "Needs review"
    }

    var statusDescription: String {
        if hasBlockers {
            return "Add the critical items before sending this handoff card."
        }
        if warnings.isEmpty {
            return "The card includes the core details a temporary caregiver needs."
        }
        return "The card can be shared, but a few optional details would make it safer."
    }

    var priorityItems: [HandoffReadinessItem] {
        items.sorted { lhs, rhs in
            severityRank(lhs.severity) < severityRank(rhs.severity)
        }
    }

    private func severityRank(_ severity: HandoffReadinessSeverity) -> Int {
        switch severity {
        case .blocker:
            return 0
        case .warning:
            return 1
        case .info:
            return 2
        }
    }
}

enum HandoffReadiness {
    static func evaluate(for pet: PetProfile, draft: HandoffCardDraft? = nil) -> HandoffReadinessReport {
        var items: [HandoffReadinessItem] = []

        if pet.name.isBlank {
            items.append(
                .init(
                    id: "missing-dog-name",
                    title: "Add the dog name",
                    detail: "The caregiver needs a clear dog name on the exported card.",
                    severity: .blocker
                )
            )
        }

        if pet.ageText.isBlank && pet.breed.isBlank {
            items.append(
                .init(
                    id: "missing-profile-context",
                    title: "Add age or breed",
                    detail: "Age or breed helps caregivers identify the dog and understand senior-care context.",
                    severity: .warning
                )
            )
        }

        evaluateCareRules(pet: pet, items: &items)
        evaluateMedications(pet: pet, items: &items)
        evaluateContacts(pet: pet, items: &items)

        if let draft = draft {
            evaluateDraft(draft, items: &items)
        }

        let blockerPenalty = items.filter { $0.severity == .blocker }.count * 18
        let warningPenalty = items.filter { $0.severity == .warning }.count * 8
        let score = max(0, min(100, 100 - blockerPenalty - warningPenalty))

        return HandoffReadinessReport(score: score, items: items)
    }

    private static func evaluateCareRules(pet: PetProfile, items: inout [HandoffReadinessItem]) {
        guard let careRule = pet.primaryCareRule else {
            items.append(
                .init(
                    id: "missing-care-rules",
                    title: "Add daily care rules",
                    detail: "Feeding, water, walks, and no-go rules are the core of a temporary handoff.",
                    severity: .blocker
                )
            )
            return
        }

        if careRule.feedingAmount.isBlank {
            items.append(
                .init(
                    id: "missing-feeding",
                    title: "Add feeding instructions",
                    detail: "A caregiver should not need to guess meal amount or frequency.",
                    severity: .blocker
                )
            )
        }

        if careRule.walkFrequency.isBlank {
            items.append(
                .init(
                    id: "missing-walks",
                    title: "Add walk frequency",
                    detail: "Walk timing keeps the day predictable for a senior dog.",
                    severity: .warning
                )
            )
        }

        if careRule.callOwnerNowText.isBlank {
            items.append(
                .init(
                    id: "missing-call-owner",
                    title: "Add call-owner triggers",
                    detail: "List the signs that should make the caregiver call you immediately.",
                    severity: .warning
                )
            )
        }

        if careRule.goVetNowText.isBlank {
            items.append(
                .init(
                    id: "missing-vet-guidance",
                    title: "Add emergency vet guidance",
                    detail: "The handoff should say when to go directly to a vet.",
                    severity: .warning
                )
            )
        }
    }

    private static func evaluateMedications(pet: PetProfile, items: inout [HandoffReadinessItem]) {
        if pet.sortedMedications.isEmpty {
            items.append(
                .init(
                    id: "no-medications",
                    title: "Confirm medication status",
                    detail: "If the dog takes no medication, leave this as a conscious empty state.",
                    severity: .info
                )
            )
            return
        }

        for medication in pet.sortedMedications {
            let displayName = medication.name.ifBlank("Unnamed medication")

            if medication.name.isBlank {
                items.append(
                    .init(
                        id: "missing-medication-name-\(medication.primarySortKey)",
                        title: "Name every medication",
                        detail: "One medication entry is missing its name.",
                        severity: .blocker
                    )
                )
            }

            if medication.dosage.isBlank {
                items.append(
                    .init(
                        id: "missing-dose-\(displayName)",
                        title: "Add dose for \(displayName)",
                        detail: "Dose must be explicit before a temporary caregiver gives medication.",
                        severity: .blocker
                    )
                )
            }

            if medication.timeSlots.isEmpty && medication.frequencyText.isBlank {
                items.append(
                    .init(
                        id: "missing-schedule-\(displayName)",
                        title: "Add timing for \(displayName)",
                        detail: "Use exact times or a clear frequency such as twice daily.",
                        severity: .blocker
                    )
                )
            }

            if medication.missedDoseInstruction.isBlank {
                items.append(
                    .init(
                        id: "missing-missed-dose-\(displayName)",
                        title: "Add missed-dose rule for \(displayName)",
                        detail: "This avoids double-dosing or unsafe make-up doses.",
                        severity: .warning
                    )
                )
            }
        }
    }

    private static func evaluateContacts(pet: PetProfile, items: inout [HandoffReadinessItem]) {
        let owner = pet.sortedContacts.first { $0.role == "Owner" }
        if owner == nil || owner?.phone.isBlank == true {
            items.append(
                .init(
                    id: "missing-owner-phone",
                    title: "Add owner phone",
                    detail: "The exported card needs an owner contact that works outside the app.",
                    severity: .blocker
                )
            )
        }

        let clinic = pet.sortedContacts.first { $0.role == "Clinic" }
        if clinic == nil || clinic?.phone.isBlank == true {
            items.append(
                .init(
                    id: "missing-clinic-phone",
                    title: "Add clinic phone",
                    detail: "A vet or clinic phone should be available in emergencies.",
                    severity: .warning
                )
            )
        }
    }

    private static func evaluateDraft(_ draft: HandoffCardDraft, items: inout [HandoffReadinessItem]) {
        if draft.caregiverName.isBlank {
            items.append(
                .init(
                    id: "missing-caregiver-name",
                    title: "Add caregiver name",
                    detail: "Naming the recipient makes reused cards less ambiguous.",
                    severity: .warning
                )
            )
        }

        if draft.endDate < draft.startDate {
            items.append(
                .init(
                    id: "invalid-coverage-window",
                    title: "Fix coverage dates",
                    detail: "End time should be after the start time.",
                    severity: .blocker
                )
            )
        }
    }
}

private extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
