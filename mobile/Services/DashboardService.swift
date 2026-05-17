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
        let retries = max(1, AppConfig.shared.dashboardRetryCount)
        var attempt = 0
        var delay: UInt64 = 300_000_000 // 300ms

        while true {
            do {
                let dashboard = try await APIClient.shared.request(DashboardEndpoint.dashboard)
                NetworkLogger.shared.log(level: "info", message: "Dashboard loaded successfully on attempt \(attempt + 1)")
                AppConfig.shared.lastSuccessfulConnection = Date()
                return dashboard
            } catch {
                attempt += 1
                NetworkLogger.shared.log(level: "warning", message: "Dashboard fetch failed on attempt \(attempt): \(error.localizedDescription)")
                if attempt >= retries {
                    NetworkLogger.shared.log(level: "error", message: "Dashboard fetch failed after \(attempt) attempts")
                    throw error
                }
                let jitter = UInt64.random(in: 0..<100_000_000)
                let sleepDuration = min(delay + jitter, 5_000_000_000)
                try? await Task.sleep(nanoseconds: sleepDuration)
                delay = min(delay * 2, 5_000_000_000)
            }
        }
    }
}
