import Foundation

struct Stock: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

struct FinnhubQuote: Codable {
    let currentPrice: Double
    let change: Double
    let changePercent: Double
    
    enum CodingKeys: String, CodingKey {
        case currentPrice = "c"
        case change = "d"
        case changePercent = "dp"
    }
}
