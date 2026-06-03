import SwiftUI

struct TransactionHistoryView: View {
    @StateObject private var viewModel: TransactionHistoryViewModel
    @State private var showFilters = false
    @State private var showSortMenu = false
    @State private var showDatePicker = false
    @State private var datePickerType: DatePickerType = .start

    enum DatePickerType {
        case start
        case end
    }

    init(cardId: String) {
        let cardIdInt = Int(cardId) ?? 0
        _viewModel = StateObject(wrappedValue: TransactionHistoryViewModel(cardId: cardIdInt))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.platformSystemBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search and Filter Bar
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search merchant...", text: $viewModel.filter.searchText)
                                .onChange(of: viewModel.filter.searchText) {
                                    viewModel.applyFiltering()
                                }
                        }
                        .padding(10)
                        .background(Color.platformSecondaryBackground)
                        .cornerRadius(8)

                        Button(action: { showFilters = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.blue)
                                .padding(10)
                                .background(Color.platformSecondaryBackground)
                                .cornerRadius(8)
                        }

                        Menu {
                            Picker("Sort", selection: $viewModel.sortBy) {
                                Text("Date (Newest)").tag(TransactionHistoryViewModel.SortOption.dateDescending)
                                Text("Date (Oldest)").tag(TransactionHistoryViewModel.SortOption.dateAscending)
                                Text("Amount (High)").tag(TransactionHistoryViewModel.SortOption.amountDescending)
                                Text("Amount (Low)").tag(TransactionHistoryViewModel.SortOption.amountAscending)
                            }
                            .onChange(of: viewModel.sortBy) {
                                viewModel.updateSort(viewModel.sortBy)
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.blue)
                                .padding(10)
                                .background(Color.platformSecondaryBackground)
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)

                    // Summary Statistics
                    if !viewModel.filteredTransactions.isEmpty {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Spent")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("₹\(String(format: "%.2f", viewModel.totalSpending()))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Transactions")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(viewModel.filteredTransactions.count)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Average")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("₹\(String(format: "%.2f", viewModel.averageTransaction()))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .background(Color.platformSecondaryBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }

                    // Transaction List
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            Text("Failed to Load")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            Button(action: {
                                Task {
                                    await viewModel.refreshTransactions()
                                }
                            }) {
                                Text("Try Again")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.filteredTransactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No Transactions")
                                .font(.headline)
                            Text("Try adjusting your filters or search")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.filteredTransactions) { transaction in
                                TransactionRowView(transaction: transaction)
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.refreshTransactions()
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .sheet(isPresented: $showFilters) {
                TransactionFilterView(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.loadTransactions()
                }
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    var categoryColor: Color {
        switch transaction.category?.lowercased() {
        case "groceries":
            return .green
        case "dining", "food":
            return .orange
        case "travel", "fuel":
            return .purple
        case "entertainment":
            return .pink
        case "shopping":
            return .blue
        case "utilities":
            return .cyan
        default:
            return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Circle()
                .fill(categoryColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: categoryIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(categoryColor)
                )

            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.merchantName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("₹\(String(format: "%.2f", transaction.amount))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        if transaction.status != "completed" {
                            Text(transaction.status.capitalized)
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }

                HStack(spacing: 8) {
                    if let category = transaction.category {
                        Label(category.capitalized, systemImage: "tag")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text(transaction.transactionDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 12)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.platformSystemBackground)
    }

    private var categoryIcon: String {
        switch transaction.category?.lowercased() {
        case "groceries":
            return "cart"
        case "dining", "food":
            return "fork.knife"
        case "travel", "fuel":
            return "car"
        case "entertainment":
            return "ticket"
        case "shopping":
            return "bag"
        case "utilities":
            return "bolt"
        default:
            return "questionmark.circle"
        }
    }
}

struct TransactionFilterView: View {
    @ObservedObject var viewModel: TransactionHistoryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedCategory: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Range")) {
                    DatePicker("From", selection: $startDate, displayedComponents: .date)
                    DatePicker("To", selection: $endDate, displayedComponents: .date)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag(Optional<String>(nil))
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category.capitalized).tag(Optional(category))
                        }
                    }
                }

                Section {
                    Button(action: {
                        viewModel.clearFilters()
                        selectedCategory = nil
                        dismiss()
                    }) {
                        Text("Clear Filters")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filters")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if !os(macOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}
