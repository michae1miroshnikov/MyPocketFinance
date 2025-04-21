import SwiftUI
import Charts

struct StockDetailView: View {
    let stock: Stock
    @StateObject private var viewModel: StockDetailViewModel
    @State private var selectedTimeRange = "1D"
    @State private var showingShareSheet = false
    @Environment(\.presentationMode) var presentationMode
    var onDelete: (() -> Void)?
    
    let timeRanges = ["1D", "1W", "1M", "3M", "1Y", "5Y"]
    
    init(stock: Stock, onDelete: (() -> Void)? = nil) {
        self.stock = stock
        self.onDelete = onDelete
        _viewModel = StateObject(wrappedValue: StockDetailViewModel(stock: stock))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                VStack(spacing: 10) {
                    Text(stock.name)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    Text(stock.symbol)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.2f", stock.price))")
                        .font(.system(size: 36, weight: .bold))
                    
                    HStack {
                        Image(systemName: stock.change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(stock.change >= 0 ? .green : .red)
                        
                        Text("$\(String(format: "%.2f", stock.change))")
                            .foregroundColor(stock.change >= 0 ? .green : .red)
                        
                        Text("(\(String(format: "%.2f", stock.changePercent))%)")
                            .foregroundColor(stock.changePercent >= 0 ? .green : .red)
                    }
                    .font(.title3)
                }
                .padding()
                
                // Chart Section
                if !viewModel.chartData.isEmpty {
                    Chart {
                        ForEach(viewModel.chartData) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Price", dataPoint.price)
                            )
                            .interpolationMethod(.cardinal)
                            .foregroundStyle(stock.change >= 0 ? .green : .red)
                        }
                    }
                    .chartYScale(domain: viewModel.minPrice...viewModel.maxPrice)
                    .frame(height: 300)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                } else {
                    ProgressView()
                        .frame(height: 300)
                }
                
                // Time Range Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(timeRanges, id: \.self) { range in
                            Button(action: {
                                selectedTimeRange = range
                                viewModel.fetchChartData(for: range)
                            }) {
                                Text(range)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedTimeRange == range ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedTimeRange == range ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Company Information Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Company Information")
                        .font(.headline)
                    
                    if !viewModel.companyDescription.isEmpty {
                        Text(viewModel.companyDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Industry")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(viewModel.companyIndustry)
                                .font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Sector")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(viewModel.companySector)
                                .font(.subheadline)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("CEO")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(viewModel.companyCEO)
                                .font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Employees")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(viewModel.companyEmployees)
                                .font(.subheadline)
                        }
                    }
                    
                    Divider()
                    
                    if let url = URL(string: viewModel.companyWebsite) {
                        Link(destination: url) {
                            HStack {
                                Text("Website")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(viewModel.companyWebsite)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Key Statistics
                VStack(spacing: 10) {
                    HStack {
                        Text("Key Statistics")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        StatisticCard(title: "Open", value: "$\(String(format: "%.2f", viewModel.stats.open))")
                        StatisticCard(title: "High", value: "$\(String(format: "%.2f", viewModel.stats.high))")
                        StatisticCard(title: "Low", value: "$\(String(format: "%.2f", viewModel.stats.low))")
                        StatisticCard(title: "Volume", value: formatNumber(viewModel.stats.volume))
                        StatisticCard(title: "52W High", value: "$\(String(format: "%.2f", viewModel.stats.yearHigh))")
                        StatisticCard(title: "52W Low", value: "$\(String(format: "%.2f", viewModel.stats.yearLow))")
                        StatisticCard(title: "Market Cap", value: formatNumber(viewModel.stats.marketCap))
                        StatisticCard(title: "P/E Ratio", value: "\(String(format: "%.2f", viewModel.stats.peRatio))")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(activityItems: [generateShareContent()])
                }
                
                // Delete Button
                Button(action: {
                    onDelete?()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Stock")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationTitle(stock.name)
        .onAppear {
            viewModel.fetchCompanyProfile()
            viewModel.fetchStockStats()
        }
    }
    
    private func formatNumber(_ value: Int) -> String {
        let num = Double(value)
        switch num {
        case 1_000_000_000...:
            return String(format: "%.2fB", num / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.2fM", num / 1_000_000)
        case 1_000...:
            return String(format: "%.2fK", num / 1_000)
        default:
            return String(format: "%.0f", num)
        }
    }
    
    private func generateShareContent() -> String {
        """
        \(stock.name) (\(stock.symbol))
        Current Price: $\(String(format: "%.2f", stock.price))
        Change: \(stock.change >= 0 ? "+" : "")$\(String(format: "%.2f", stock.change)) (\(String(format: "%.2f", stock.changePercent))%)
        
        52W Range: $\(String(format: "%.2f", viewModel.stats.yearLow)) - $\(String(format: "%.2f", viewModel.stats.yearHigh))
        Market Cap: \(formatNumber(viewModel.stats.marketCap))
        P/E Ratio: \(String(format: "%.2f", viewModel.stats.peRatio))
        """
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
