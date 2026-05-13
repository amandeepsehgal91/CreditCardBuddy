import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    dashboardHeader
                    rewardsSummary
                    quickActions
                    cardList
                }
                .padding()
            }
            .navigationTitle("Credit Card Buddy")
            .task {
                await viewModel.loadDashboard()
            }
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Connected cards")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(viewModel.cards.count)")
                .font(.largeTitle)
                .bold()
            Text("Monthly spend ₹\(String(format: "%.0f", viewModel.totalSpend))")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rewardsSummary: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Rewards balance")
                    .font(.headline)
                Text("\(viewModel.totalRewards) points")
                    .font(.title)
                    .bold()
                Text("Recommended next redemption: Airline miles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 16) {
            ActionButton(title: "Connect card", systemImage: "link")
            ActionButton(title: "Spend insights", systemImage: "chart.bar")
            ActionButton(title: "Recommendations", systemImage: "star")
        }
    }

    private var cardList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your cards")
                .font(.headline)
            ForEach(viewModel.cards) { card in
                CreditCardRow(card: card)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemBackground))
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
    }
}

struct CreditCardRow: View {
    let card: CreditCard

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(card.cardName)
                    .font(.headline)
                Text(card.issuer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("•••• " + card.last4)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("₹\(Int(card.currentBalance))")
                    .font(.headline)
                Text("Due: \(card.dueDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
