import SwiftUI

struct DashboardSummaryView: View {
    let summary: DashboardSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total spend")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(Int(summary.monthlySpend))")
                        .font(.title)
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Rewards")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(summary.totalRewards)")
                        .font(.title3)
                        .bold()
                }
            }

            Divider()

            HStack {
                Label("\(summary.totalCards) cards", systemImage: "creditcard.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Label("Due \(summary.nextPaymentDue, style: .date)", systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(summary.nextRedemptionHint)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct DashboardSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardSummaryView(summary: DashboardSummary(totalCards: 2, monthlySpend: 9940, totalRewards: 12450, nextPaymentDue: Date().addingTimeInterval(5 * 24 * 3600), nextRedemptionHint: "Use HDFC Miles for flights"))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
