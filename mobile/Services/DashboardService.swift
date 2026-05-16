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
        let retries = AppConfig.shared.dashboardRetryCount
        var attempt = 0
        var delay: UInt64 = 300_000_000 // 300ms

        while true {
            do {
                return try await APIClient.shared.request(DashboardEndpoint.dashboard)
            } catch {
                attempt += 1
                if attempt >= max(1, retries) {
                    throw error
                }
                try? await Task.sleep(nanoseconds: delay)
                delay = min(delay * 2, 5_000_000_000) // cap at 5s
            }
        }
    }
}
