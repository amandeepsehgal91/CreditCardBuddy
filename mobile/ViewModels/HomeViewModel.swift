import Foundation

final class HomeViewModel: ObservableObject {
    @Published var summary: DashboardSummary?
    @Published var cards: [CreditCard] = []
    @Published var spendCategories: [SpendCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dashboardService = DashboardService()

    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let dashboard = try await dashboardService.fetchDashboard()
            summary = dashboard.summary
            cards = dashboard.cards
            spendCategories = dashboard.spendCategories
        } catch {
            errorMessage = "Unable to load dashboard"
        }
    }
}
