import SwiftUI

struct StockRow: View {
    let stock: Stock
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.name)
                    .font(.headline)
                Text(stock.symbol)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(String(format: "%.2f $", stock.price))
                    .font(.headline)
                Text(String(format: "%.2f%%", stock.changePercent))
                    .foregroundColor(stock.change >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
