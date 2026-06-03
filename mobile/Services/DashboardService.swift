import Foundation

struct DashboardData: Codable {
    let summary: DashboardSummary
    let cards: [CreditCard]
    let spendCategories: [SpendCategory]
}

private enum DashboardEndpoint: APIEndpoint {
    case dashboard
    case dashboardV1(userId: String)

    var path: String {
        switch self {
        case .dashboard:
            return "/dashboard"
        case .dashboardV1(let userId):
            return "/api/v1/dashboard/\(userId)"
        }
    }
}

final class DashboardService {
    func fetchDashboard() async throws -> DashboardData {
        // Return mock data if mock mode is enabled
        if AppConfig.shared.useMockData {
            return DashboardService.createMockDashboard()
        }

        let retries = max(1, AppConfig.shared.dashboardRetryCount)
        var attempt = 0
        var delay: UInt64 = 300_000_000 // 300ms

        while true {
            do {
                // Try database-backed endpoint first if user is logged in
                if let userId = UserService.shared.currentUserId {
                    let dashboard: DashboardData = try await APIClient.shared.request(DashboardEndpoint.dashboardV1(userId: userId))
                    NetworkLogger.shared.log(level: "info", message: "Dashboard loaded from database on attempt \(attempt + 1)")
                    AppConfig.shared.lastSuccessfulConnection = Date()
                    return dashboard
                }

                // Fall back to legacy mock endpoint
                let dashboard: DashboardData = try await APIClient.shared.request(DashboardEndpoint.dashboard)
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

    private static func createMockDashboard() -> DashboardData {
        let now = Date()
        let cards = [
            CreditCard(
                id: "1",
                issuer: "HDFC",
                cardName: "Millenia",
                last4: "1234",
                rewardProgram: "SmartPoints",
                currentBalance: 15420.5,
                availableCredit: 34579.5,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: now) ?? now,
                monthlySpend: 3740
            ),
            CreditCard(
                id: "2",
                issuer: "SBI",
                cardName: "Elite",
                last4: "5678",
                rewardProgram: "Cashback",
                currentBalance: 8200,
                availableCredit: 12100,
                dueDate: Calendar.current.date(byAdding: .day, value: 12, to: now) ?? now,
                monthlySpend: 6200
            )
        ]

        let totalSpend = cards.reduce(0) { $0 + $1.monthlySpend }
        let summary = DashboardSummary(
            totalCards: cards.count,
            monthlySpend: totalSpend,
            totalRewards: 12450,
            nextPaymentDue: cards[0].dueDate,
            nextRedemptionHint: "Use HDFC Miles for travel"
        )

        let spendCategories = [
            SpendCategory(name: "Dining", amount: 6200, color: "#FF9F1C", percent: 37),
            SpendCategory(name: "Travel", amount: 4200, color: "#2EC4B6", percent: 25),
            SpendCategory(name: "Groceries", amount: 3600, color: "#8D99AE", percent: 21),
            SpendCategory(name: "Shopping", amount: 2400, color: "#EF476F", percent: 17)
        ]

        return DashboardData(summary: summary, cards: cards, spendCategories: spendCategories)
    }
}
