import SwiftUI

struct StockView: View {
    @StateObject private var viewModel = StockViewModel()
    @State private var newSymbol: String = ""
    @State private var selectedStock: Stock? = nil
    @AppStorage("savedStocks") private var savedStocksData: Data = Data()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Input for new stock symbol
                    VStack(spacing: 10) {
                        Text("Add Stock")
                            .font(.title2)
                        
                        HStack {
                            TextField("Stock symbol", text: $newSymbol)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                guard !newSymbol.isEmpty else { return }
                                viewModel.fetchStockData(for: newSymbol.uppercased())
                                saveStockSymbol(newSymbol.uppercased())
                                newSymbol = ""
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Stock list
                    VStack(alignment: .leading) {
                        Text("My Stocks")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(viewModel.stocks) { stock in
                            StockRow(stock: stock)
                                .onTapGesture {
                                    selectedStock = stock
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            viewModel.removeStock(stock)
                                            removeStockSymbol(stock.symbol)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
            .sheet(item: $selectedStock) { stock in
                StockDetailView(stock: stock, onDelete: {
                    withAnimation {
                        viewModel.removeStock(stock)
                        removeStockSymbol(stock.symbol)
                    }
                })
            }
            .navigationTitle("Stock Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refreshAll()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                loadSavedStocks()
            }
        }
    }
    
    private func loadSavedStocks() {
        guard let savedStocks = try? JSONDecoder().decode([String].self, from: savedStocksData) else { return }
        savedStocks.forEach { symbol in
            viewModel.fetchStockData(for: symbol)
        }
    }
    
    private func saveStockSymbol(_ symbol: String) {
        var savedStocks = (try? JSONDecoder().decode([String].self, from: savedStocksData)) ?? []
        if !savedStocks.contains(symbol) {
            savedStocks.append(symbol)
            if let encoded = try? JSONEncoder().encode(savedStocks) {
                savedStocksData = encoded
            }
        }
    }
    
    private func removeStockSymbol(_ symbol: String) {
        var savedStocks = (try? JSONDecoder().decode([String].self, from: savedStocksData)) ?? []
        savedStocks.removeAll { $0 == symbol }
        if let encoded = try? JSONEncoder().encode(savedStocks) {
            savedStocksData = encoded
        }
    }
}
