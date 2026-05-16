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

        do {
        // Launch-time connectivity check with one automatic retry
            _ = try await healthService.fetchHealth()
        } catch {
            // first attempt failed — retry once after short delay
            try? await Task.sleep(nanoseconds: 700_000_000) // 700ms
            do {
                _ = try await healthService.fetchHealth()
            } catch {
                errorMessage = "Cannot reach backend: \(error.localizedDescription)"
                return
            }
        }

        do {
            let dashboard = try await dashboardService.fetchDashboard()
            summary = dashboard.summary
            cards = dashboard.cards
            spendCategories = dashboard.spendCategories
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
