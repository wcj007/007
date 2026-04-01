import SwiftUI
import SwiftData

@main
struct DogHandoffCardApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(
            for: [
                PetProfile.self,
                MedicationItem.self,
                CareRule.self,
                EmergencyContact.self,
                HandoffCardRecord.self
            ]
        )
    }
}
