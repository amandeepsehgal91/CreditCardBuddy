import Foundation

final class UserService {
    static let shared = UserService()
    private init() {}

    private let userIdKey = "CurrentUserId"

    var currentUserId: String? {
        get {
            UserDefaults.standard.string(forKey: userIdKey)
        }
        set {
            if let id = newValue {
                UserDefaults.standard.set(id, forKey: userIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userIdKey)
            }
        }
    }

    func setCurrentUser(id: String) {
        currentUserId = id
    }

    func clearCurrentUser() {
        currentUserId = nil
    }

    func isLoggedIn() -> Bool {
        currentUserId != nil
    }
}
