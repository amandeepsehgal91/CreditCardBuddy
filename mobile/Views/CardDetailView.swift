import SwiftUI

struct CardDetailView: View {
    let card: CreditCard
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Card Visual
                        CardVisualView(card: card)
                            .padding()

                        // Tab selector
                        Picker("", selection: $selectedTab) {
                            Text("Overview").tag(0)
                            Text("Rewards").tag(1)
                            Text("Details").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        // Tab content
                        if selectedTab == 0 {
                            overviewSection
                        } else if selectedTab == 1 {
                            rewardsSection
                        } else {
                            detailsSection
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(card.cardName)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Balance info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Current Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\(Int(card.currentBalance))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Available Credit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\(Int(card.availableCredit))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.platformSecondaryBackground)
                .cornerRadius(12)

                // Credit utilization
                let totalCredit = card.currentBalance + card.availableCredit
                let utilization = totalCredit > 0 ? Int((card.currentBalance / totalCredit) * 100) : 0
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Credit Utilization")
                            .font(.subheadline)
                        Spacer()
                        Text("\(utilization)%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    ProgressView(value: Double(utilization) / 100.0)
                        .tint(utilization > 80 ? .red : utilization > 50 ? .orange : .green)
                }
                .padding()
                .background(Color.platformSecondaryBackground)
                .cornerRadius(12)
            }

            // Monthly spend
            VStack(alignment: .leading, spacing: 8) {
                Text("Monthly Spend")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("₹\(card.monthlySpend)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.platformSecondaryBackground)
            .cornerRadius(12)

            // Due date
            VStack(alignment: .leading, spacing: 8) {
                Text("Due Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(card.dueDate, style: .date)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.platformSecondaryBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Rewards Program")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(card.rewardProgram)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.platformSecondaryBackground)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 12) {
                Text("Estimated Rewards")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                let estimatedRewards = Int(Double(card.monthlySpend) * 0.02) // 2% estimate
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Month")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\(estimatedRewards)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Annual estimate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\(estimatedRewards * 12)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.08))
                .cornerRadius(12)
            }
            .padding()
            .background(Color.platformSecondaryBackground)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 12) {
                Text("How to redeem")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Transfer to bank account", systemImage: "arrow.right.square")
                    Label("Use for travel bookings", systemImage: "airplane")
                    Label("Shopping vouchers", systemImage: "bag")
                    Label("Gift cards", systemImage: "gift")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.platformSecondaryBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailRow(label: "Card ID", value: card.id)
            Divider()
            DetailRow(label: "Issuer", value: card.issuer)
            Divider()
            DetailRow(label: "Card Number", value: "•••• •••• •••• \(card.last4)")
            Divider()
            DetailRow(label: "Reward Program", value: card.rewardProgram)
        }
        .padding()
        .background(Color.platformSecondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CardVisualView: View {
    let card: CreditCard

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.issuer)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text(card.cardName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Card Number")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("•••• •••• •••• \(card.last4)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                }
                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Valid Through")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("12/26")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("CVV")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("•••")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(card: CreditCard(
            id: "1",
            issuer: "HDFC",
            cardName: "Millenia",
            last4: "1234",
            rewardProgram: "SmartPoints",
            currentBalance: 15420.5,
            availableCredit: 34579.5,
            dueDate: Date(),
            monthlySpend: 3740
        ))
    }
}
