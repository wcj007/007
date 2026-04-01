import SwiftUI

struct ProfileView: View {
    @Bindable var pet: PetProfile

    var body: some View {
        Form {
            Section("Basic info") {
                TextField("Dog name", text: $pet.name)
                TextField("Age, for example 13 years", text: $pet.ageText)
                TextField("Breed, for example Corgi", text: $pet.breed)
                TextField("Weight, for example 12.8kg", text: $pet.weightText)
                    .keyboardType(.numbersAndPunctuation)

                Picker("Sex", selection: $pet.sex) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Not set").tag("")
                }

                Picker("Neuter status", selection: $pet.neuterStatus) {
                    Text("Neutered").tag("Neutered")
                    Text("Not neutered").tag("Not neutered")
                    Text("Not set").tag("")
                }

                TextField("Chip ID (optional)", text: $pet.chipID)
                    .keyboardType(.numbersAndPunctuation)
            }

            Section("Temperament and constraints") {
                TextField("Temperament tags, comma-separated", text: $pet.temperamentTagsText, axis: .vertical)
                TextField("Do-not-do tags, comma-separated", text: $pet.tabooTagsText, axis: .vertical)
            }

            Section("Tips") {
                Text("Include behavior details that a temporary caregiver can easily miss, such as fear of strangers, food guarding, begging, thunder anxiety, or reactivity around unfamiliar dogs.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Dog Profile")
    }
}
