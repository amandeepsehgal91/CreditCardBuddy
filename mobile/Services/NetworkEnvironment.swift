import Foundation

enum NetworkEnvironment: String, CaseIterable, Codable {
    case local
    case staging
    case production

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
        if let env = ProcessInfo.processInfo.environment["API_ENVIRONMENT"],
           let environment = NetworkEnvironment(rawValue: env) {
            return environment
        }
        return .local
    }

    static var baseURL: URL {
        if let override = ProcessInfo.processInfo.environment["API_BASE_URL"],
           let url = URL(string: override) {
            return url
        }
        return URL(string: current.baseURLString)!
    }
}
