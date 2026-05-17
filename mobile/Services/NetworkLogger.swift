import Foundation

struct NetworkLogEntry: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: String
    let message: String
}

final class NetworkLogger {
    static let shared = NetworkLogger()
    private init() {}

    private let storageKey = "NetworkLoggerEntries"
    private let maxEntries = 20

    var entries: [NetworkLogEntry] {
        get {
            guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
            return (try? JSONDecoder().decode([NetworkLogEntry].self, from: data)) ?? []
        }
        set {
            let clipped = Array(newValue.suffix(maxEntries))
            if let data = try? JSONEncoder().encode(clipped) {
                UserDefaults.standard.set(data, forKey: storageKey)
            }
        }
    }

    func log(level: String, message: String) {
        let entry = NetworkLogEntry(timestamp: Date(), level: level, message: message)
        var current = entries
        current.append(entry)
        entries = current
        print("[NetworkLogger] [\(level.uppercased())] \(message)")
    }

    func clear() {
        entries = []
    }
}
