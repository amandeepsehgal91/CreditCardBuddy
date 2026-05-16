import Foundation

enum NetworkEnvironment: String, CaseIterable, Codable {
    case local
    case staging
    case production

    private static let userDefaultsKey = "CurrentNetworkEnvironment"

    var displayName: String {
        switch self {
        case .local:
            return "Local"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }

    var baseURLString: String {
        switch self {
        case .local:
            return "http://127.0.0.1:4000"
        case .staging:
            return "https://staging-api.creditcardbuddy.com"
        case .production:
            return "https://api.creditcardbuddy.com"
        }
    }

    static var current: NetworkEnvironment {
        if let savedValue = UserDefaults.standard.string(forKey: userDefaultsKey),
           let savedEnvironment = NetworkEnvironment(rawValue: savedValue) {
            return savedEnvironment
        }

        if let env = ProcessInfo.processInfo.environment["API_ENVIRONMENT"],
           let environment = NetworkEnvironment(rawValue: env) {
            return environment
        }

        return .local
    }

    static func setCurrent(_ environment: NetworkEnvironment) {
        UserDefaults.standard.set(environment.rawValue, forKey: userDefaultsKey)
    }

    static var baseURL: URL {
        if let override = ProcessInfo.processInfo.environment["API_BASE_URL"],
           let url = URL(string: override) {
            return url
        }
        return URL(string: current.baseURLString)!
    }
}
