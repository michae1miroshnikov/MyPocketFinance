import SwiftUI

struct ExchangeRatesView: View {
    @StateObject private var viewModel = ExchangeRatesViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Base Currency: USD")) {
                    ForEach(viewModel.filteredRates, id: \.key) { code, rate in
                        HStack {
                            Text(code)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(rate, specifier: "%.4f")")
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Exchange Rates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.fetchRates()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                viewModel.fetchRates()
            }
        }
    }
}

class ExchangeRatesViewModel: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var error: String?
    @Published var isLoading = false
    
    private let apiKey = "c1338d80c82bb212d09f626570e5831c"
    private let targetCurrencies = ["EUR", "UAH"]
    
    var filteredRates: [(key: String, value: Double)] {
        rates.filter { targetCurrencies.contains($0.key) }
            .sorted { $0.key < $1.key }
            .map { ("\($0.key)", $0.value) }
    }
    
    func fetchRates() {
        isLoading = true
        error = nil
        
        let urlString = "http://api.exchangerate.host/live?access_key=\(apiKey)&source=USD"
        
        guard let url = URL(string: urlString) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ExchangeAPIResponse.self, from: data)
                    if response.success {
                        self?.rates = response.quotes
                    } else {
                        self?.error = "API Error: \(response.error?.info ?? "Unknown error")"
                    }
                } catch {
                    self?.error = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct ExchangeAPIResponse: Codable {
    let success: Bool
    let quotes: [String: Double]
    let error: ErrorInfo?
    
    struct ErrorInfo: Codable {
        let info: String
    }
}
