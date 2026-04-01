import SwiftUI

struct HomeView: View {
    let pet: PetProfile
    @Binding var selection: DogHandoffTab

    private var latestCard: HandoffCardRecord? {
        pet.sortedCards.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                overviewSection
                latestCardSection
                quickActionsSection
            }
            .padding()
        }
        .navigationTitle("Home")
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Three minutes before a trip, send a handoff card that helps the next caregiver avoid medication mistakes.")
                .font(.title2.bold())

            Text("This is not a general pet journal. It is a standard handoff card for temporary caregivers who may not even have the app installed.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("iPhone local-only", systemImage: "iphone")
                Label("Image / PDF / text export", systemImage: "square.and.arrow.up")
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.orange.opacity(0.12))
        )
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current data")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Dog name", value: pet.name.ifBlank("Not set"), systemImage: "pawprint.fill")
                StatCard(title: "Medications", value: "\(pet.medications.count)", systemImage: "pills.fill")
                StatCard(title: "Contacts", value: "\(pet.contacts.count)", systemImage: "person.2.fill")
                StatCard(title: "Saved cards", value: "\(pet.cards.count)", systemImage: "doc.text.fill")
            }
        }
    }

    private var latestCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Latest handoff card")
                .font(.headline)

            if let latestCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text(latestCard.title)
                        .font(.headline)
                    Text("\(latestCard.caregiverType.ifBlank("Caregiver")) | \(latestCard.caregiverName.ifBlank("TBD"))")
                        .foregroundStyle(.secondary)
                    Text("Generated \(DateFormatter.handoffDate.string(from: latestCard.generatedAt)) | v\(latestCard.version)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Duplicate and edit") {
                        selection = .handoff
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            } else {
                ContentUnavailableView(
                    "No handoff cards yet",
                    systemImage: "doc.badge.plus",
                    description: Text("Finish the dog profile and care rules, then create the first handoff card.")
                )
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick start")
                .font(.headline)

            Button {
                selection = .profile
            } label: {
                ActionRow(
                    title: "Complete the dog profile",
                    subtitle: "Name, age, breed, temperament tags, no-go tags",
                    systemImage: "pawprint"
                )
            }
            .buttonStyle(.plain)

            Button {
                selection = .care
            } label: {
                ActionRow(
                    title: "Add medications and care rules",
                    subtitle: "Drug names, times, food rules, contacts",
                    systemImage: "list.bullet.clipboard"
                )
            }
            .buttonStyle(.plain)

            Button {
                selection = .handoff
            } label: {
                ActionRow(
                    title: "Create and share a handoff card",
                    subtitle: "Export image, PDF, and plain text",
                    systemImage: "square.and.arrow.up"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.orange)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct ActionRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.orange.opacity(0.12)))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
