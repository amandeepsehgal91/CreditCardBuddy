import Foundation

struct DashboardData: Codable {
    let summary: DashboardSummary
    let cards: [CreditCard]
    let spendCategories: [SpendCategory]
}

private enum DashboardEndpoint: APIEndpoint {
    case dashboard

    var path: String {
        switch self {
        case .dashboard:
            return "/dashboard"
        }
    }
}

final class DashboardService {
    func fetchDashboard() async throws -> DashboardData {
        try await APIClient.shared.request(DashboardEndpoint.dashboard)
    }
}
