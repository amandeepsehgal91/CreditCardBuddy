import Foundation

/// Configuration for different app environments
struct EnvironmentConfig {
    let name: String
    let displayName: String
    let baseURL: URL
    let analyticsEnabled: Bool
    let loggingLevel: LogLevel
    let featureFlags: [String: Bool]
    let description: String

    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
}

/// Centralized app environment configuration
final class AppEnvironmentConfig {
    static let shared = AppEnvironmentConfig()
    private init() {}

    private let environmentKey = "SelectedEnvironment"
    private let customBaseURLKey = "CustomBaseURL"
    private let featureFlagsKey = "FeatureFlags"

    var selectedEnvironment: String {
        get {
            UserDefaults.standard.string(forKey: environmentKey) ?? "local"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: environmentKey)
        }
    }

    var customBaseURL: String? {
        get {
            UserDefaults.standard.string(forKey: customBaseURLKey)
        }
        set {
            if let url = newValue {
                UserDefaults.standard.set(url, forKey: customBaseURLKey)
            } else {
                UserDefaults.standard.removeObject(forKey: customBaseURLKey)
            }
        }
    }

    var featureFlags: [String: Bool] {
        get {
            (UserDefaults.standard.dictionary(forKey: featureFlagsKey) as? [String: Bool]) ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: featureFlagsKey)
        }
    }

    // Predefined environment configurations
    let configs: [String: EnvironmentConfig] = [
        "local": EnvironmentConfig(
            name: "local",
            displayName: "Local Development",
            baseURL: URL(string: "http://127.0.0.1:4000") ?? URL(fileURLWithPath: "/"),
            analyticsEnabled: false,
            loggingLevel: .debug,
            featureFlags: [
                "transactionHistory": true,
                "analytics": false,
                "accountAggregator": false,
                "mockDataMode": true,
                "debugPanel": true,
            ],
            description: "Local machine (http://127.0.0.1:4000)"
        ),
        "staging": EnvironmentConfig(
            name: "staging",
            displayName: "Staging",
            baseURL: URL(string: "https://staging-api.creditcardbuddy.com") ?? URL(fileURLWithPath: "/"),
            analyticsEnabled: true,
            loggingLevel: .info,
            featureFlags: [
                "transactionHistory": true,
                "analytics": true,
                "accountAggregator": true,
                "mockDataMode": false,
                "debugPanel": true,
            ],
            description: "Staging server with real data"
        ),
        "production": EnvironmentConfig(
            name: "production",
            displayName: "Production",
            baseURL: URL(string: "https://api.creditcardbuddy.com") ?? URL(fileURLWithPath: "/"),
            analyticsEnabled: true,
            loggingLevel: .warning,
            featureFlags: [
                "transactionHistory": true,
                "analytics": true,
                "accountAggregator": true,
                "mockDataMode": false,
                "debugPanel": false,
            ],
            description: "Production environment"
        ),
    ]

    func getConfig(for environment: String) -> EnvironmentConfig? {
        configs[environment]
    }

    func currentConfig() -> EnvironmentConfig? {
        getConfig(for: selectedEnvironment)
    }

    func isFeatureFlagEnabled(_ flag: String) -> Bool {
        if let config = currentConfig() {
            return config.featureFlags[flag] ?? false
        }
        return false
    }

    func setFeatureFlag(_ flag: String, enabled: Bool) {
        var flags = featureFlags
        flags[flag] = enabled
        featureFlags = flags
    }

    func allEnvironments() -> [EnvironmentConfig] {
        ["local", "staging", "production"].compactMap { configs[$0] }
    }
}
