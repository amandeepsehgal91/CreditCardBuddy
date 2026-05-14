import Foundation

struct DashboardSummary: Codable {
    let totalCards: Int
    let monthlySpend: Double
    let totalRewards: Int
    let nextPaymentDue: Date
    let nextRedemptionHint: String
}
