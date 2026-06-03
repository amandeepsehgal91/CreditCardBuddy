import Foundation

@MainActor
class TransactionHistoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var filter = TransactionFilter()
    @Published var sortBy: SortOption = .dateDescending
    @Published var categories: [String] = []

    enum SortOption {
        case dateAscending
        case dateDescending
        case amountAscending
        case amountDescending
    }

    private let cardId: Int
    private let transactionService = TransactionService.shared

    init(cardId: Int) {
        self.cardId = cardId
    }

    func loadTransactions() async {
        isLoading = true
        error = nil

        do {
            transactions = try await transactionService.fetchTransactions(for: cardId)
            extractCategories()
            applyFiltering()
        } catch {
            self.error = "Failed to load transactions: \(error.localizedDescription)"
            transactions = []
        }

        isLoading = false
    }

    func refreshTransactions() async {
        await loadTransactions()
    }

    func applyFiltering() {
        filteredTransactions = transactions.filter { filter.matches($0) }
        applySorting()
    }

    private func applySorting() {
        switch sortBy {
        case .dateAscending:
            filteredTransactions.sort { $0.transactionDate < $1.transactionDate }
        case .dateDescending:
            filteredTransactions.sort { $0.transactionDate > $1.transactionDate }
        case .amountAscending:
            filteredTransactions.sort { $0.amount < $1.amount }
        case .amountDescending:
            filteredTransactions.sort { $0.amount > $1.amount }
        }
    }

    func updateFilter(_ newFilter: TransactionFilter) {
        filter = newFilter
        applyFiltering()
    }

    func updateSort(_ option: SortOption) {
        sortBy = option
        applySorting()
    }

    func clearFilters() {
        filter = TransactionFilter()
        applyFiltering()
    }

    private func extractCategories() {
        let categorySet = Set(transactions.compactMap { $0.category })
        categories = Array(categorySet).sorted()
    }

    func categorySpending() -> [String: Double] {
        var spending: [String: Double] = [:]
        for transaction in filteredTransactions {
            let category = transaction.category ?? "Other"
            spending[category, default: 0] += transaction.amount
        }
        return spending
    }

    func totalSpending() -> Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    func averageTransaction() -> Double {
        guard !filteredTransactions.isEmpty else { return 0 }
        return totalSpending() / Double(filteredTransactions.count)
    }
}
