import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEnvironment = NetworkEnvironment.current
    @State private var selectedRetryCount = AppConfig.shared.dashboardRetryCount
    @State private var healthStatus: String = "Unknown"
    @State private var isCheckingHealth = false
    @State private var healthMessage: String = ""
    @State private var recentLogs: [NetworkLogEntry] = NetworkLogger.shared.entries

    private let healthService = HealthService()

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

                Section(header: Text("Retry policy")) {
                    Stepper("Retry attempts: \(selectedRetryCount)", value: $selectedRetryCount, in: 0...10)
                    Text("Number of times to retry dashboard fetch (exponential backoff).")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Backend health")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        if isCheckingHealth {
                            ProgressView()
                        } else {
                            Text(healthStatus)
                                .foregroundColor(healthStatus == "ok" ? .green : .secondary)
                        }
                    }

                    if !healthMessage.isEmpty {
                        Text(healthMessage)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    if let lastSuccess = AppConfig.shared.lastSuccessfulConnection {
                        Text("Last successful connection: \(lastSuccess, style: .relative)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Button("Check connection") {
                        Task {
                            await checkHealth()
                        }
                    }
                }

                if !recentLogs.isEmpty {
                    Section(header: Text("Recent network logs")) {
                        ForEach(Array(recentLogs.prefix(3))) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.message)
                                    .font(.subheadline)
                                Text(entry.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        NetworkEnvironment.setCurrent(selectedEnvironment)
                        AppConfig.shared.dashboardRetryCount = selectedRetryCount
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await checkHealth()
                recentLogs = NetworkLogger.shared.entries
            }
        }
    }

    private func checkHealth() async {
        isCheckingHealth = true
        healthMessage = ""
        do {
            let health = try await healthService.fetchHealth()
            healthStatus = health.status
            AppConfig.shared.lastSuccessfulConnection = Date()
            NetworkLogger.shared.log(level: "info", message: "Health check succeeded")
        } catch {
            healthStatus = "failed"
            healthMessage = error.localizedDescription
            NetworkLogger.shared.log(level: "warning", message: "Health check failed: \(error.localizedDescription)")
        }
        recentLogs = NetworkLogger.shared.entries
        isCheckingHealth = false
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
