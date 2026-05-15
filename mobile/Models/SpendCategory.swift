import Foundation

struct SpendCategory: Identifiable, Codable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: String
    let percent: Double

    enum CodingKeys: String, CodingKey {
        case name, amount, color, percent
    }
}
