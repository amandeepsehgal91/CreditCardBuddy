import SwiftUI
#if os(macOS)
import AppKit
#endif

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var isShowingSettings = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Inline error banner with retry
                    if let error = viewModel.errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .frame(width: 20)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            HStack(spacing: 8) {
                                Button(action: { Task { await viewModel.loadDashboard() } }) {
                                    Text("Retry")
                                        .font(.subheadline)
                                }
                                .buttonStyle(.bordered)
                                
                                Button(action: { isShowingSettings = true }) {
                                    Text("Settings")
                                        .font(.subheadline)
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Backend not reachable?")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Text("Try enabling 'Use mock data' in Settings to test the app without a backend server.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                    if let summary = viewModel.summary {
                        DashboardSummaryView(summary: summary)
                    }

                    quickActions

                    spendSection
                    cardList
                }
                .padding()
            }
            .refreshable {
                await viewModel.loadDashboard()
            }
            .navigationTitle("Credit Card Buddy")
            .toolbar {
                ToolbarItem(placement: homeToolbarLeadingPlacement) {
                    Button(action: {
                        Task { await viewModel.loadDashboard() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }

                ToolbarItem(placement: homeToolbarTrailingPlacement) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .task {
                await viewModel.loadDashboard()
            }
            .overlay(loadingOverlay)
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 14) {
            ActionButton(title: "Connect card", systemImage: "link")
            ActionButton(title: "Spend insights", systemImage: "chart.bar")
            ActionButton(title: "Recommendations", systemImage: "star")
        }
    }

    private var spendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top spend categories")
                .font(.headline)
            ForEach(viewModel.spendCategories) { category in
                SpendCategoryRow(category: category)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var cardList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your cards")
                    .font(.headline)
                Spacer()
                NavigationLink("View all") {
                    Text("")
                }
            }

            ForEach(viewModel.cards) { card in
                NavigationLink(destination: CardDetailView(card: card)) {
                    CreditCardRow(card: card)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView("Loading dashboard...")
                            .padding(24)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                    )
            }
        }
    }

    private var homeToolbarLeadingPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .navigationBarLeading
        #endif
    }

    private var homeToolbarTrailingPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .navigationBarTrailing
        #endif
    }
}

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.platformSecondaryBackground)
            .overlay(content.padding())
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.platformSystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
    }
}

struct CreditCardRow: View {
    let card: CreditCard

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.cardName)
                        .font(.headline)
                    Text(card.issuer)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("•••• " + card.last4)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(Int(card.currentBalance))")
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Due")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(card.dueDate, style: .date)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.platformSecondaryBackground)
        .cornerRadius(18)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
