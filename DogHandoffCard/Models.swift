import Foundation
import SwiftData

@Model
final class PetProfile {
    var createdAt: Date
    var name: String
    var ageText: String
    var breed: String
    var weightText: String
    var sex: String
    var neuterStatus: String
    var chipID: String
    var temperamentTagsText: String
    var tabooTagsText: String

    @Relationship(deleteRule: .cascade, inverse: \MedicationItem.pet)
    var medications: [MedicationItem] = []

    @Relationship(deleteRule: .cascade, inverse: \CareRule.pet)
    var careRules: [CareRule] = []

    @Relationship(deleteRule: .cascade, inverse: \EmergencyContact.pet)
    var contacts: [EmergencyContact] = []

    @Relationship(deleteRule: .cascade, inverse: \HandoffCardRecord.pet)
    var cards: [HandoffCardRecord] = []

    init(
        createdAt: Date = .now,
        name: String = "",
        ageText: String = "",
        breed: String = "",
        weightText: String = "",
        sex: String = "Male",
        neuterStatus: String = "Neutered",
        chipID: String = "",
        temperamentTagsText: String = "",
        tabooTagsText: String = ""
    ) {
        self.createdAt = createdAt
        self.name = name
        self.ageText = ageText
        self.breed = breed
        self.weightText = weightText
        self.sex = sex
        self.neuterStatus = neuterStatus
        self.chipID = chipID
        self.temperamentTagsText = temperamentTagsText
        self.tabooTagsText = tabooTagsText
    }

    var primaryCareRule: CareRule? {
        careRules.first
    }

    var sortedCards: [HandoffCardRecord] {
        cards.sorted { $0.generatedAt > $1.generatedAt }
    }

    var sortedMedications: [MedicationItem] {
        medications.sorted { $0.primarySortKey < $1.primarySortKey }
    }

    var sortedContacts: [EmergencyContact] {
        contacts.sorted { lhs, rhs in
            let left = EmergencyContact.roleRank(for: lhs.role)
            let right = EmergencyContact.roleRank(for: rhs.role)
            if left == right {
                return lhs.name < rhs.name
            }
            return left < right
        }
    }
}

@Model
final class MedicationItem {
    var name: String
    var form: String
    var dosage: String
    var frequencyText: String
    var specificTimes: String
    var withFood: Bool
    var needsSplitting: Bool
    var hideInFood: Bool
    var missedDoseInstruction: String
    var startDate: Date
    var endDate: Date?
    var notes: String

    var pet: PetProfile?

    init(
        name: String = "",
        form: String = "Tablet",
        dosage: String = "",
        frequencyText: String = "",
        specificTimes: String = "",
        withFood: Bool = false,
        needsSplitting: Bool = false,
        hideInFood: Bool = false,
        missedDoseInstruction: String = "",
        startDate: Date = .now,
        endDate: Date? = nil,
        notes: String = ""
    ) {
        self.name = name
        self.form = form
        self.dosage = dosage
        self.frequencyText = frequencyText
        self.specificTimes = specificTimes
        self.withFood = withFood
        self.needsSplitting = needsSplitting
        self.hideInFood = hideInFood
        self.missedDoseInstruction = missedDoseInstruction
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }

    var primarySortKey: String {
        timeSlots.first ?? "99:99"
    }

    var timeSlots: [String] {
        specificTimes
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .sorted()
    }
}

@Model
final class CareRule {
    var feedingAmount: String
    var waterNotes: String
    var walkFrequency: String
    var forbiddenFoodsText: String
    var cannotDoText: String
    var triggerWarningsText: String
    var callOwnerNowText: String
    var goVetNowText: String
    var handoffTipsText: String

    var pet: PetProfile?

    init(
        feedingAmount: String = "",
        waterNotes: String = "",
        walkFrequency: String = "",
        forbiddenFoodsText: String = "",
        cannotDoText: String = "",
        triggerWarningsText: String = "",
        callOwnerNowText: String = "",
        goVetNowText: String = "",
        handoffTipsText: String = ""
    ) {
        self.feedingAmount = feedingAmount
        self.waterNotes = waterNotes
        self.walkFrequency = walkFrequency
        self.forbiddenFoodsText = forbiddenFoodsText
        self.cannotDoText = cannotDoText
        self.triggerWarningsText = triggerWarningsText
        self.callOwnerNowText = callOwnerNowText
        self.goVetNowText = goVetNowText
        self.handoffTipsText = handoffTipsText
    }
}

@Model
final class EmergencyContact {
    var role: String
    var name: String
    var phone: String
    var address: String
    var note: String

    var pet: PetProfile?

    init(
        role: String = "Owner",
        name: String = "",
        phone: String = "",
        address: String = "",
        note: String = ""
    ) {
        self.role = role
        self.name = name
        self.phone = phone
        self.address = address
        self.note = note
    }

    static func roleRank(for role: String) -> Int {
        switch role {
        case "Owner":
            return 0
        case "Backup":
            return 1
        case "Clinic":
            return 2
        case "Boarding":
            return 3
        default:
            return 9
        }
    }
}

@Model
final class HandoffCardRecord {
    var title: String
    var caregiverName: String
    var caregiverType: String
    var startDate: Date
    var endDate: Date
    var customNote: String
    var version: Int
    var generatedAt: Date
    var whoSection: String
    var mustDoSection: String
    var medicationSection: String
    var callOwnerSection: String
    var goVetSection: String
    var contactSection: String
    var plainText: String

    var pet: PetProfile?

    init(
        title: String,
        caregiverName: String,
        caregiverType: String,
        startDate: Date,
        endDate: Date,
        customNote: String,
        version: Int,
        generatedAt: Date = .now,
        whoSection: String,
        mustDoSection: String,
        medicationSection: String,
        callOwnerSection: String,
        goVetSection: String,
        contactSection: String,
        plainText: String
    ) {
        self.title = title
        self.caregiverName = caregiverName
        self.caregiverType = caregiverType
        self.startDate = startDate
        self.endDate = endDate
        self.customNote = customNote
        self.version = version
        self.generatedAt = generatedAt
        self.whoSection = whoSection
        self.mustDoSection = mustDoSection
        self.medicationSection = medicationSection
        self.callOwnerSection = callOwnerSection
        self.goVetSection = goVetSection
        self.contactSection = contactSection
        self.plainText = plainText
    }

    var snapshot: HandoffCardSnapshot {
        HandoffCardSnapshot(
            title: title,
            subtitle: "\(caregiverType.ifBlank("Caregiver")) | \(caregiverName.ifBlank("TBD")) | v\(version)",
            generatedAt: generatedAt,
            whoSection: whoSection,
            mustDoSection: mustDoSection,
            medicationSection: medicationSection,
            callOwnerSection: callOwnerSection,
            goVetSection: goVetSection,
            contactSection: contactSection,
            plainText: plainText
        )
    }
}

struct HandoffCardDraft: Identifiable, Hashable {
    let id: UUID
    var title: String
    var caregiverName: String
    var caregiverType: String
    var startDate: Date
    var endDate: Date
    var customNote: String
    var version: Int

    init(
        id: UUID = UUID(),
        title: String = "Care Handoff Card",
        caregiverName: String = "",
        caregiverType: String = "Family / Boarding",
        startDate: Date = .now,
        endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
        customNote: String = "",
        version: Int = 1
    ) {
        self.id = id
        self.title = title
        self.caregiverName = caregiverName
        self.caregiverType = caregiverType
        self.startDate = startDate
        self.endDate = endDate
        self.customNote = customNote
        self.version = version
    }

    init(duplicating card: HandoffCardRecord) {
        self.init(
            title: card.title,
            caregiverName: card.caregiverName,
            caregiverType: card.caregiverType,
            startDate: .now,
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
            customNote: card.customNote,
            version: card.version + 1
        )
    }
}

struct HandoffCardSnapshot {
    var title: String
    var subtitle: String
    var generatedAt: Date
    var whoSection: String
    var mustDoSection: String
    var medicationSection: String
    var callOwnerSection: String
    var goVetSection: String
    var contactSection: String
    var plainText: String
}

extension String {
    func ifBlank(_ fallback: String) -> String {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }

    var splitLines: [String] {
        split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }
}

extension DateFormatter {
    static let handoffDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    static let shortDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}
