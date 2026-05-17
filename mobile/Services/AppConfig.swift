import Foundation

final class AppConfig {
    static let shared = AppConfig()
    private init() {}

    private let retryKey = "DashboardRetryCount"
    private let lastSuccessKey = "LastSuccessfulConnection"
    private let mockModeKey = "UseMockData"

    var useMockData: Bool {
        get {
            UserDefaults.standard.bool(forKey: mockModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: mockModeKey)
        }
    }

    var dashboardRetryCount: Int {
        get {
            if let v = UserDefaults.standard.object(forKey: retryKey) as? Int {
                return v
            }
            // default based on environment
            switch NetworkEnvironment.current {
            case .local: return 1
            case .staging: return 2
            case .production: return 3
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: retryKey)
        }
    }

    var lastSuccessfulConnection: Date? {
        get {
            UserDefaults.standard.object(forKey: lastSuccessKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastSuccessKey)
        }
    }
}
