import Foundation

final class HomeViewModel: ObservableObject {
    @Published var summary: DashboardSummary?
    @Published var cards: [CreditCard] = []
    @Published var spendCategories: [SpendCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dashboardService = DashboardService()
    private let healthService = HealthService()

    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }

        if !AppConfig.shared.useMockData {
            do {
                // Launch-time connectivity check with one automatic retry
                _ = try await healthService.fetchHealth()
            } catch {
                // first attempt failed — retry once after short delay
                let jitter = UInt64.random(in: 0..<200_000_000)
                try? await Task.sleep(nanoseconds: 700_000_000 + jitter)
                do {
                    _ = try await healthService.fetchHealth()
                } catch {
                    let message = "Cannot reach backend: \(error.localizedDescription)"
                    NetworkLogger.shared.log(level: "error", message: message)
                    errorMessage = message
                    return
                }
            }
        }

        do {
            let dashboard = try await dashboardService.fetchDashboard()
            summary = dashboard.summary
            cards = dashboard.cards
            spendCategories = dashboard.spendCategories
            AppConfig.shared.lastSuccessfulConnection = Date()
        } catch {
            let message = "Dashboard load failed: \(error.localizedDescription)"
            NetworkLogger.shared.log(level: "error", message: message)
            errorMessage = message
        }
    }
}
