import Foundation

private enum TransactionEndpoint: APIEndpoint {
    case transactions(cardId: Int)
    case transactionsWithFilters(cardId: Int, queryItems: [URLQueryItem])

    var path: String {
        switch self {
        case .transactions(let cardId):
            return "/api/v1/cards/\(cardId)/transactions"
        case .transactionsWithFilters(let cardId, _):
            return "/api/v1/cards/\(cardId)/transactions"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .transactions:
            return nil
        case .transactionsWithFilters(_, let items):
            return items.isEmpty ? nil : items
        }
    }
}

class TransactionService {
    static let shared = TransactionService()
    private let apiClient = APIClient.shared

    func fetchTransactions(for cardId: Int) async throws -> [Transaction] {
        let endpoint = TransactionEndpoint.transactions(cardId: cardId)
        let response: [Transaction] = try await apiClient.request(endpoint)
        return response
    }

    func searchTransactions(
        for cardId: Int,
        query: String?,
        category: String?,
        startDate: Date?,
        endDate: Date?
    ) async throws -> [Transaction] {
        var queryParams: [URLQueryItem] = []

        if let q = query, !q.isEmpty {
            queryParams.append(URLQueryItem(name: "search", value: q))
        }
        if let cat = category, !cat.isEmpty {
            queryParams.append(URLQueryItem(name: "category", value: cat))
        }
        if let start = startDate {
            let formatter = ISO8601DateFormatter()
            queryParams.append(URLQueryItem(name: "startDate", value: formatter.string(from: start)))
        }
        if let end = endDate {
            let formatter = ISO8601DateFormatter()
            queryParams.append(URLQueryItem(name: "endDate", value: formatter.string(from: end)))
        }

        let endpoint = TransactionEndpoint.transactionsWithFilters(cardId: cardId, queryItems: queryParams)
        let response: [Transaction] = try await apiClient.request(endpoint)
        return response
    }
}
