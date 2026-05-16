import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEnvironment = NetworkEnvironment.current

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Environment")) {
                    ForEach(NetworkEnvironment.allCases, id: \.self) { environment in
                        Button(action: {
                            selectedEnvironment = environment
                        }) {
                            HStack {
                                Text(environment.displayName)
                                Spacer()
                                if selectedEnvironment == environment {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section(header: Text("Current base URL")) {
                    Text(selectedEnvironment.baseURLString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        NetworkEnvironment.setCurrent(selectedEnvironment)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
