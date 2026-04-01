import SwiftUI
import SwiftData
import UIKit

struct HandoffView: View {
    @Environment(\.modelContext) private var modelContext
    let pet: PetProfile

    @State private var draft = HandoffCardDraft()
    @State private var hasInitializedDraft = false
    @State private var shareItems: [Any] = []
    @State private var showingShareSheet = false
    @State private var alertMessage = ""
    @State private var showingAlert = false

    private var snapshot: HandoffCardSnapshot {
        HandoffCardBuilder.build(for: pet, draft: draft)
    }

    var body: some View {
        Form {
            Section {
                Text("Turn scattered instructions into one standard handoff card that a temporary caregiver can actually use.")
                    .foregroundStyle(.secondary)
            }

            Section("Recent cards") {
                if pet.sortedCards.isEmpty {
                    Text("There are no saved cards yet. Fill in the handoff details below and save the first one.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(pet.sortedCards.prefix(3))) { card in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(card.title)
                                .font(.headline)
                            Text("\(card.caregiverType.ifBlank("Caregiver")) | \(card.caregiverName.ifBlank("TBD")) | v\(card.version)")
                                .foregroundStyle(.secondary)
                            Text("Generated \(DateFormatter.handoffDate.string(from: card.generatedAt))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Button("Duplicate this card") {
                                draft = HandoffCardDraft(duplicating: card)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("Current handoff") {
                TextField("Card title", text: $draft.title)
                TextField("Caregiver name", text: $draft.caregiverName)
                TextField("Caregiver type", text: $draft.caregiverType)
                DatePicker("Start time", selection: $draft.startDate)
                DatePicker("End time", selection: $draft.endDate)
                Stepper("Version \(draft.version)", value: $draft.version, in: 1...99)
                TextField("Trip-specific note", text: $draft.customNote, axis: .vertical)
            }

            Section("Preview") {
                HandoffCardPreviewView(snapshot: snapshot)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
            }

            Section("Save and export") {
                Button("Save as a new card") {
                    saveCurrentCard()
                }

                Button("Share image / PDF / text file") {
                    shareCurrentCard()
                }

                Button("Copy plain text summary") {
                    UIPasteboard.general.string = snapshot.plainText
                    showMessage("Plain text summary copied.")
                }
            }
        }
        .navigationTitle("Handoff Card")
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
        .alert("Notice", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            initializeDraftIfNeeded()
        }
    }

    private func initializeDraftIfNeeded() {
        guard !hasInitializedDraft else { return }
        hasInitializedDraft = true
        if let latest = pet.sortedCards.first {
            draft = HandoffCardDraft(duplicating: latest)
        }
    }

    private func saveCurrentCard() {
        let record = HandoffCardBuilder.makeRecord(for: pet, draft: draft, snapshot: snapshot)
        modelContext.insert(record)
        record.pet = pet
        try? modelContext.save()
        draft = HandoffCardDraft(duplicating: record)
        showMessage("The card was saved and the next draft was bumped to the next version for reuse.")
    }

    private func shareCurrentCard() {
        do {
            shareItems = try ExportService.makeShareItems(snapshot: snapshot)
            showingShareSheet = true
        } catch {
            showMessage(error.localizedDescription)
        }
    }

    private func showMessage(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

struct HandoffCardPreviewView: View {
    let snapshot: HandoffCardSnapshot

    var body: some View {
        HandoffCardLayout(snapshot: snapshot, useSurfaceBackground: true)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
    }
}

struct HandoffCardPrintView: View {
    let snapshot: HandoffCardSnapshot

    var body: some View {
        HandoffCardLayout(snapshot: snapshot, useSurfaceBackground: false)
            .padding(28)
            .background(Color.white)
    }
}

private struct HandoffCardLayout: View {
    let snapshot: HandoffCardSnapshot
    let useSurfaceBackground: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(snapshot.title)
                    .font(.system(size: 30, weight: .bold))
                Text(snapshot.subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("Generated: \(DateFormatter.handoffDate.string(from: snapshot.generatedAt))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            PreviewSectionBlock(title: "1. Dog Profile", bodyText: snapshot.whoSection, useSurfaceBackground: useSurfaceBackground)
            PreviewSectionBlock(title: "2. Must Do Today", bodyText: snapshot.mustDoSection, useSurfaceBackground: useSurfaceBackground)
            PreviewSectionBlock(title: "3. Medication Instructions", bodyText: snapshot.medicationSection, useSurfaceBackground: useSurfaceBackground)
            PreviewSectionBlock(title: "4. Call Owner Immediately If", bodyText: snapshot.callOwnerSection, useSurfaceBackground: useSurfaceBackground)
            PreviewSectionBlock(title: "5. Go To Vet Immediately If", bodyText: snapshot.goVetSection, useSurfaceBackground: useSurfaceBackground)
            PreviewSectionBlock(title: "6. Contacts", bodyText: snapshot.contactSection, useSurfaceBackground: useSurfaceBackground)
        }
    }
}

private struct PreviewSectionBlock: View {
    let title: String
    let bodyText: String
    let useSurfaceBackground: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(bodyText.splitLines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .font(.body)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(useSurfaceBackground ? Color(.systemBackground) : Color(.secondarySystemBackground))
        )
    }
}
