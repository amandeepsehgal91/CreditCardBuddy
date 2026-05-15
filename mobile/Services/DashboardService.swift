import Foundation

struct DashboardData: Codable {
    let summary: DashboardSummary
    let cards: [CreditCard]
    let spendCategories: [SpendCategory]
}

enum DashboardServiceError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid dashboard URL."
        case let .invalidResponse(statusCode, message):
            return "Server error (\(statusCode)): \(message)"
        }
    }
}

final class DashboardService {
    private let dashboardURLString = "http://127.0.0.1:4000/dashboard"

    func fetchDashboard() async throws -> DashboardData {
        guard let url = URL(string: dashboardURLString) else {
            throw DashboardServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DashboardServiceError.invalidResponse(statusCode: -1, message: "No HTTP response received.")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw DashboardServiceError.invalidResponse(statusCode: httpResponse.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DashboardData.self, from: data)
    }
}
