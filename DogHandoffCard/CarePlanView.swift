import SwiftUI
import SwiftData

struct CarePlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var pet: PetProfile

    @State private var editingMedication: MedicationItem?
    @State private var showingNewMedication = false
    @State private var editingContact: EmergencyContact?
    @State private var showingNewContact = false

    var body: some View {
        Form {
            medicationSection
            careRuleSection
            contactSection
        }
        .navigationTitle("Care Rules")
        .sheet(isPresented: $showingNewMedication) {
            NavigationStack {
                MedicationEditorView(pet: pet)
            }
        }
        .sheet(item: $editingMedication) { medication in
            NavigationStack {
                MedicationEditorView(pet: pet, medication: medication)
            }
        }
        .sheet(isPresented: $showingNewContact) {
            NavigationStack {
                ContactEditorView(pet: pet)
            }
        }
        .sheet(item: $editingContact) { contact in
            NavigationStack {
                ContactEditorView(pet: pet, contact: contact)
            }
        }
        .task {
            ensureCareRuleExists()
        }
    }

    private var medicationSection: some View {
        Section("Medications") {
            if pet.sortedMedications.isEmpty {
                Text("No medications yet. Add drug name, time, food rule, and missed-dose instructions first.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(pet.sortedMedications) { medication in
                    Button {
                        editingMedication = medication
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(medication.name.ifBlank("Unnamed medication"))
                                .foregroundStyle(.primary)
                            Text("\(medication.timeSlots.joined(separator: " / ").ifBlank(medication.frequencyText.ifBlank("No time set"))) | \(medication.dosage.ifBlank("No dose set"))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteMedications)
            }

            Button("Add medication") {
                showingNewMedication = true
            }
        }
    }

    private var careRuleSection: some View {
        Section("Daily care rules") {
            if let careRule = pet.primaryCareRule {
                TextField("Feeding amount and frequency", text: Binding(
                    get: { careRule.feedingAmount },
                    set: { careRule.feedingAmount = $0 }
                ))
                TextField("Water notes", text: Binding(
                    get: { careRule.waterNotes },
                    set: { careRule.waterNotes = $0 }
                ), axis: .vertical)
                TextField("Walk frequency", text: Binding(
                    get: { careRule.walkFrequency },
                    set: { careRule.walkFrequency = $0 }
                ))
                TextField("Foods to avoid", text: Binding(
                    get: { careRule.forbiddenFoodsText },
                    set: { careRule.forbiddenFoodsText = $0 }
                ), axis: .vertical)
                TextField("Do-not-do rules", text: Binding(
                    get: { careRule.cannotDoText },
                    set: { careRule.cannotDoText = $0 }
                ), axis: .vertical)
                TextField("Watch items / triggers", text: Binding(
                    get: { careRule.triggerWarningsText },
                    set: { careRule.triggerWarningsText = $0 }
                ), axis: .vertical)
                TextField("Call owner immediately if", text: Binding(
                    get: { careRule.callOwnerNowText },
                    set: { careRule.callOwnerNowText = $0 }
                ), axis: .vertical)
                TextField("Go to the vet immediately if", text: Binding(
                    get: { careRule.goVetNowText },
                    set: { careRule.goVetNowText = $0 }
                ), axis: .vertical)
                TextField("Extra handoff notes", text: Binding(
                    get: { careRule.handoffTipsText },
                    set: { careRule.handoffTipsText = $0 }
                ), axis: .vertical)
            }
        }
    }

    private var contactSection: some View {
        Section("Contacts") {
            if pet.sortedContacts.isEmpty {
                Text("At least add the owner and clinic contact details.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(pet.sortedContacts) { contact in
                    Button {
                        editingContact = contact
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(contact.role.ifBlank("Contact")) | \(contact.name.ifBlank("Not set"))")
                                .foregroundStyle(.primary)
                            Text(contact.phone.ifBlank("No phone set"))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteContacts)
            }

            Button("Add contact") {
                showingNewContact = true
            }
        }
    }

    private func ensureCareRuleExists() {
        guard pet.primaryCareRule == nil else { return }
        let careRule = CareRule()
        modelContext.insert(careRule)
        careRule.pet = pet
        try? modelContext.save()
    }

    private func deleteMedications(at offsets: IndexSet) {
        let list = pet.sortedMedications
        for offset in offsets {
            modelContext.delete(list[offset])
        }
        try? modelContext.save()
    }

    private func deleteContacts(at offsets: IndexSet) {
        let list = pet.sortedContacts
        for offset in offsets {
            modelContext.delete(list[offset])
        }
        try? modelContext.save()
    }
}

private struct MedicationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let pet: PetProfile
    let medication: MedicationItem?

    @State private var name: String
    @State private var form: String
    @State private var dosage: String
    @State private var frequencyText: String
    @State private var specificTimes: String
    @State private var withFood: Bool
    @State private var needsSplitting: Bool
    @State private var hideInFood: Bool
    @State private var missedDoseInstruction: String
    @State private var startDate: Date
    @State private var hasEndDate: Bool
    @State private var endDate: Date
    @State private var notes: String

    init(pet: PetProfile, medication: MedicationItem? = nil) {
        self.pet = pet
        self.medication = medication
        _name = State(initialValue: medication?.name ?? "")
        _form = State(initialValue: medication?.form ?? "Tablet")
        _dosage = State(initialValue: medication?.dosage ?? "")
        _frequencyText = State(initialValue: medication?.frequencyText ?? "")
        _specificTimes = State(initialValue: medication?.specificTimes ?? "")
        _withFood = State(initialValue: medication?.withFood ?? false)
        _needsSplitting = State(initialValue: medication?.needsSplitting ?? false)
        _hideInFood = State(initialValue: medication?.hideInFood ?? false)
        _missedDoseInstruction = State(initialValue: medication?.missedDoseInstruction ?? "")
        _startDate = State(initialValue: medication?.startDate ?? .now)
        _hasEndDate = State(initialValue: medication?.endDate != nil)
        _endDate = State(initialValue: medication?.endDate ?? .now)
        _notes = State(initialValue: medication?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("Medication details") {
                TextField("Medication name", text: $name)
                TextField("Form, for example tablet / liquid", text: $form)
                TextField("Dose, for example 1 tablet / 2ml", text: $dosage)
                TextField("Frequency, for example twice daily", text: $frequencyText)
                TextField("Exact times, comma-separated", text: $specificTimes)
                    .keyboardType(.numbersAndPunctuation)
            }

            Section("How to give it") {
                Toggle("Give with food", isOn: $withFood)
                Toggle("Needs splitting", isOn: $needsSplitting)
                Toggle("Can hide in food", isOn: $hideInFood)
                TextField("Missed-dose instructions", text: $missedDoseInstruction, axis: .vertical)
                TextField("Extra notes", text: $notes, axis: .vertical)
            }

            Section("Date range") {
                DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                Toggle("Set end date", isOn: $hasEndDate)
                if hasEndDate {
                    DatePicker("End date", selection: $endDate, displayedComponents: .date)
                }
            }
        }
        .navigationTitle(medication == nil ? "Add Medication" : "Edit Medication")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        let target = medication ?? MedicationItem()

        if medication == nil {
            modelContext.insert(target)
            target.pet = pet
        }

        target.name = name
        target.form = form
        target.dosage = dosage
        target.frequencyText = frequencyText
        target.specificTimes = specificTimes
        target.withFood = withFood
        target.needsSplitting = needsSplitting
        target.hideInFood = hideInFood
        target.missedDoseInstruction = missedDoseInstruction
        target.startDate = startDate
        target.endDate = hasEndDate ? endDate : nil
        target.notes = notes

        try? modelContext.save()
        dismiss()
    }
}

private struct ContactEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let pet: PetProfile
    let contact: EmergencyContact?

    @State private var role: String
    @State private var name: String
    @State private var phone: String
    @State private var address: String
    @State private var note: String

    init(pet: PetProfile, contact: EmergencyContact? = nil) {
        self.pet = pet
        self.contact = contact
        _role = State(initialValue: contact?.role ?? "Owner")
        _name = State(initialValue: contact?.name ?? "")
        _phone = State(initialValue: contact?.phone ?? "")
        _address = State(initialValue: contact?.address ?? "")
        _note = State(initialValue: contact?.note ?? "")
    }

    var body: some View {
        Form {
            Section("Contact details") {
                Picker("Role", selection: $role) {
                    Text("Owner").tag("Owner")
                    Text("Backup").tag("Backup")
                    Text("Clinic").tag("Clinic")
                    Text("Boarding").tag("Boarding")
                }

                TextField("Name / clinic", text: $name)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Address", text: $address, axis: .vertical)
                TextField("Notes", text: $note, axis: .vertical)
            }
        }
        .navigationTitle(contact == nil ? "Add Contact" : "Edit Contact")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        let target = contact ?? EmergencyContact()

        if contact == nil {
            modelContext.insert(target)
            target.pet = pet
        }

        target.role = role
        target.name = name
        target.phone = phone
        target.address = address
        target.note = note

        try? modelContext.save()
        dismiss()
    }
}
