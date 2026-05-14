import Foundation

struct DashboardData {
    let summary: DashboardSummary
    let cards: [CreditCard]
    let spendCategories: [SpendCategory]
}

final class DashboardService {
    func fetchDashboard() async throws -> DashboardData {
        try await Task.sleep(nanoseconds: 200_000_000)

        let cards = [
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

        let spendCategories = [
            SpendCategory(name: "Dining", amount: 6200, color: "#FF9F1C", percent: 37),
            SpendCategory(name: "Travel", amount: 4200, color: "#2EC4B6", percent: 25),
            SpendCategory(name: "Groceries", amount: 3600, color: "#8D99AE", percent: 21),
            SpendCategory(name: "Shopping", amount: 2400, color: "#EF476F", percent: 17)
        ]

        let summary = DashboardSummary(
            totalCards: cards.count,
            monthlySpend: cards.reduce(0) { $0 + $1.monthlySpend },
            totalRewards: 12450,
            nextPaymentDue: Date().addingTimeInterval(5 * 24 * 3600),
            nextRedemptionHint: "Use HDFC Miles for flights"
        )

        return DashboardData(summary: summary, cards: cards, spendCategories: spendCategories)
    }
}
