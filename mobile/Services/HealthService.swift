import Foundation

struct HealthResponse: Codable {
    let status: String
}

private enum HealthEndpoint: APIEndpoint {
    case status

    var path: String {
        switch self {
        case .status:
            return "/health"
        }
    }
}

final class HealthService {
    func fetchHealth() async throws -> HealthResponse {
        try await APIClient.shared.request(HealthEndpoint.status)
    }
}
