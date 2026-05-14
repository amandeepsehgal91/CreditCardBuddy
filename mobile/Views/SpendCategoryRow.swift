import SwiftUI

struct SpendCategoryRow: View {
    let category: SpendCategory

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: category.color))
                .frame(width: 14, height: 14)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.subheadline)
                    .bold()
                Text("₹\(Int(category.amount)) • \(Int(category.percent))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct SpendCategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        SpendCategoryRow(category: SpendCategory(name: "Dining", amount: 6200, color: "#FF9F1C", percent: 37))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
