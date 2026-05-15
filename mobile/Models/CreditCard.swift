import Foundation

struct CreditCard: Identifiable, Codable {
    let id: String
    let issuer: String
    let cardName: String
    let last4: String
    let rewardProgram: String
    let currentBalance: Double
    let availableCredit: Double
    let dueDate: Date
    let monthlySpend: Double
}
