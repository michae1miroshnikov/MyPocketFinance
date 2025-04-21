import Foundation
import Combine

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

struct StockStats {
    var open: Double = 0
    var high: Double = 0
    var low: Double = 0
    var volume: Int = 0
    var yearHigh: Double = 0
    var yearLow: Double = 0
    var marketCap: Int = 0
    var peRatio: Double = 0
}

class StockDetailViewModel: ObservableObject {
    @Published var chartData: [ChartDataPoint] = []
    @Published var stats = StockStats()
    @Published var companyDescription = ""
    @Published var companyIndustry = ""
    @Published var companySector = ""
    @Published var companyCEO = ""
    @Published var companyEmployees = ""
    @Published var companyWebsite = ""
    
    let stock: Stock
    private let apiKey = "cvff6a9r01qtu9s4fssgcvff6a9r01qtu9s4fst0"
    
    var minPrice: Double {
        chartData.map { $0.price }.min() ?? stock.price * 0.95
    }
    
    var maxPrice: Double {
        chartData.map { $0.price }.max() ?? stock.price * 1.05
    }
    
    var xAxisStride: Calendar.Component {
        if chartData.count > 30 { return .month }
        if chartData.count > 7 { return .day }
        return .hour
    }
    
    var xAxisFormat: Date.FormatStyle {
        if chartData.count > 30 { return .dateTime.month(.abbreviated).day() }
        if chartData.count > 7 { return .dateTime.weekday(.abbreviated).day() }
        return .dateTime.hour().minute()
    }
    
    init(stock: Stock) {
        self.stock = stock
        // Initialize with some default stats
        stats.open = stock.price * 0.98
        stats.high = stock.price * 1.05
        stats.low = stock.price * 0.95
        stats.volume = Int.random(in: 1_000_000...100_000_000)
        stats.yearHigh = stock.price * 1.2
        stats.yearLow = stock.price * 0.8
        stats.marketCap = Int.random(in: 100_000_000...1_000_000_000_000)
        stats.peRatio = Double.random(in: 5...50)
    }
    
    func fetchChartData(for range: String) {
        // In a real app, you would fetch this from an API
        // Here we generate mock data based on the time range
        var dataPoints: [ChartDataPoint] = []
        let now = Date()
        let calendar = Calendar.current
        
        let count: Int
        let component: Calendar.Component
        let value: Int
        
        switch range {
        case "1D":
            count = 24
            component = .hour
            value = -1
        case "1W":
            count = 7
            component = .day
            value = -1
        case "1M":
            count = 30
            component = .day
            value = -1
        case "3M":
            count = 12
            component = .weekOfYear
            value = -1
        case "1Y":
            count = 12
            component = .month
            value = -1
        case "5Y":
            count = 5
            component = .year
            value = -1
        default:
            count = 7
            component = .day
            value = -1
        }
        
        for i in 0..<count {
            guard let date = calendar.date(byAdding: component, value: i * value, to: now) else { continue }
            let basePrice = stock.price
            let priceVariation = Double.random(in: -0.05...0.05)
            let price = basePrice * (1 + priceVariation)
            dataPoints.append(ChartDataPoint(date: date, price: price))
        }
        
        // Sort by date (newest first)
        chartData = dataPoints.sorted { $0.date > $1.date }
    }
    
    func fetchStockStats() {
        // In a real app, fetch from API
        // Using mock data for now
        stats.open = stock.price * Double.random(in: 0.98...1.02)
        stats.high = stock.price * Double.random(in: 1.02...1.10)
        stats.low = stock.price * Double.random(in: 0.90...0.98)
        stats.volume = Int.random(in: 1_000_000...100_000_000)
        stats.yearHigh = stock.price * Double.random(in: 1.15...1.30)
        stats.yearLow = stock.price * Double.random(in: 0.70...0.85)
        stats.marketCap = Int.random(in: 100_000_000...1_000_000_000_000)
        stats.peRatio = Double.random(in: 5...50)
    }
    
    func fetchCompanyProfile() {
        // In a real app, you would fetch this from an API
        // Using mock data for now - these would come from API calls
        
        let companyProfiles: [String: (String, String, String, String, String, String)] = [
            "AAPL": ("Apple Inc.", "Consumer Electronics", "Technology", "Tim Cook", "164,000", "https://www.apple.com"),
            "MSFT": ("Microsoft Corporation", "Software - Infrastructure", "Technology", "Satya Nadella", "221,000", "https://www.microsoft.com"),
            "GOOG": ("Alphabet Inc.", "Internet Content & Information", "Communication Services", "Sundar Pichai", "156,500", "https://abc.xyz"),
            "TSLA": ("Tesla Inc.", "Auto Manufacturers", "Consumer Cyclical", "Elon Musk", "127,855", "https://www.tesla.com"),
            "AMZN": ("Amazon.com Inc.", "Internet Retail", "Consumer Cyclical", "Andy Jassy", "1,608,000", "https://www.amazon.com")
        ]
        
        if let profile = companyProfiles[stock.symbol] {
            companyDescription = "\(profile.0) is a leading company in the \(profile.1) industry. It operates in the \(profile.2) sector and is headquartered in Cupertino, California."
            companyIndustry = profile.1
            companySector = profile.2
            companyCEO = profile.3
            companyEmployees = profile.4
            companyWebsite = profile.5
        } else {
            companyDescription = "\(stock.name) is a publicly traded company. Detailed information about this company is not currently available."
            companyIndustry = "N/A"
            companySector = "N/A"
            companyCEO = "N/A"
            companyEmployees = "N/A"
            companyWebsite = "N/A"
        }
    }
}
