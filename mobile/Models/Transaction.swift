import Foundation

struct Transaction: Codable, Identifiable {
    let id: Int
    let cardId: Int
    let merchantName: String
    let category: String?
    let amount: Double
    let transactionDate: Date
    let description: String?
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case cardId = "card_id"
        case merchantName = "merchant_name"
        case category
        case amount
        case transactionDate = "transaction_date"
        case description
        case status
    }
}

struct TransactionFilter {
    var startDate: Date?
    var endDate: Date?
    var category: String?
    var searchText: String = ""
    var minAmount: Double?
    var maxAmount: Double?

    func matches(_ transaction: Transaction) -> Bool {
        // Date range filter
        if let start = startDate, transaction.transactionDate < start {
            return false
        }
        if let end = endDate, transaction.transactionDate > end {
            return false
        }

        // Category filter
        if let cat = category, transaction.category != cat {
            return false
        }

        // Amount range filter
        if let min = minAmount, transaction.amount < min {
            return false
        }
        if let max = maxAmount, transaction.amount > max {
            return false
        }

        // Search text filter
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            let merchantMatches = transaction.merchantName.lowercased().contains(searchLower)
            let descriptionMatches = transaction.description?.lowercased().contains(searchLower) ?? false
            return merchantMatches || descriptionMatches
        }

        return true
    }
}
