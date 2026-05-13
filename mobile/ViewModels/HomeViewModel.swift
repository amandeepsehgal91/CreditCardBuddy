import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var cards: [CreditCard] = []
    @Published var totalSpend: Double = 0
    @Published var totalRewards: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // TODO: replace with backend + AA integration
            try await Task.sleep(nanoseconds: 300_000_000)
            cards = [
                CreditCard(
                    id: UUID(),
                    issuer: "HDFC",
                    cardName: "Millenia",
                    last4: "1234",
                    rewardProgram: "SmartPoints",
                    currentBalance: 15420.50,
                    availableCredit: 34579.50,
                    dueDate: Date().addingTimeInterval(5 * 24 * 3600),
                    monthlySpend: 3740.00
                ),
                CreditCard(
                    id: UUID(),
                    issuer: "SBI",
                    cardName: "Elite",
                    last4: "5678",
                    rewardProgram: "Cashback",
                    currentBalance: 8200.00,
                    availableCredit: 12100.00,
                    dueDate: Date().addingTimeInterval(12 * 24 * 3600),
                    monthlySpend: 6200.00
                )
            ]
            totalSpend = cards.reduce(0) { $0 + $1.monthlySpend }
            totalRewards = 12450
        } catch {
            errorMessage = "Unable to load dashboard"
        }
    }
}
