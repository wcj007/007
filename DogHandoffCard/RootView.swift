import SwiftUI
import SwiftData

enum DogHandoffTab: Hashable {
    case home
    case profile
    case care
    case handoff
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PetProfile.createdAt) private var pets: [PetProfile]
    @State private var selection: DogHandoffTab = .home

    var body: some View {
        Group {
            if let pet = pets.first {
                TabView(selection: $selection) {
                    NavigationStack {
                        HomeView(pet: pet, selection: $selection)
                    }
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(DogHandoffTab.home)

                    NavigationStack {
                        ProfileView(pet: pet)
                    }
                    .tabItem {
                        Label("Profile", systemImage: "pawprint")
                    }
                    .tag(DogHandoffTab.profile)

                    NavigationStack {
                        CarePlanView(pet: pet)
                    }
                    .tabItem {
                        Label("Care", systemImage: "list.clipboard")
                    }
                    .tag(DogHandoffTab.care)

                    NavigationStack {
                        HandoffView(pet: pet)
                    }
                    .tabItem {
                        Label("Handoff", systemImage: "square.and.arrow.up")
                    }
                    .tag(DogHandoffTab.handoff)
                }
            } else {
                starterView
            }
        }
        .tint(.orange)
    }

    private var starterView: some View {
        NavigationStack {
            ContentUnavailableView(
                "Dog Handoff Card",
                systemImage: "heart.text.square",
                description: Text("Before a trip, create a clear handoff card so the next caregiver can avoid medication mistakes.")
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Get started") {
                        createStarterProfile()
                    }
                }
            }
        }
    }

    private func createStarterProfile() {
        let pet = PetProfile()
        let careRule = CareRule()
        let owner = EmergencyContact(role: "Owner")

        modelContext.insert(pet)
        modelContext.insert(careRule)
        modelContext.insert(owner)

        careRule.pet = pet
        owner.pet = pet

        try? modelContext.save()
    }
}
