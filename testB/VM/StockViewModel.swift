import Foundation
import Combine

class StockViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "cvff6a9r01qtu9s4fssgcvff6a9r01qtu9s4fst0"
    
    func fetchStockData(for symbol: String) {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(FinnhubQuote.self, from: data)
                    let stock = Stock(
                        symbol: symbol,
                        name: symbol,
                        price: decodedData.currentPrice,
                        change: decodedData.change,
                        changePercent: decodedData.changePercent
                    )
                    self?.addStock(stock)
                } catch {
                    self?.errorMessage = "Failed to parse JSON: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func addStock(_ stock: Stock) {
        if !stocks.contains(stock) {
            stocks.append(stock)
        }
    }
    
    func removeStock(_ stock: Stock) {
        stocks.removeAll { $0 == stock }
    }
    
    func refreshAll() {
        let symbols = stocks.map { $0.symbol }
        stocks.removeAll()
        symbols.forEach { fetchStockData(for: $0) }
    }
}
