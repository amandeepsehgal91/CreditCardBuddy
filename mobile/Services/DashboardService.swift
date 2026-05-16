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
    func fetchDashboard(retries: Int = 3) async throws -> DashboardData {
        var attempt = 0
        var delay: UInt64 = 300_000_000 // 300ms

        while true {
            do {
                return try await APIClient.shared.request(DashboardEndpoint.dashboard)
            } catch {
                attempt += 1
                if attempt >= retries {
                    throw error
                }
                try? await Task.sleep(nanoseconds: delay)
                delay *= 2
            }
        }
    }
}
