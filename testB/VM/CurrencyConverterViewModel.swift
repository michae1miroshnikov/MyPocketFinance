//
//  CurrencyConverterViewModel.swift
//  testB
//
//  Created by Michael Miroshnikov on 14/04/2025.
//

import Foundation

class CurrencyConverterViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var sourceCurrency: String = "USD"
    @Published var targetCurrency: String = "EUR"
    @Published var convertedValue: Double?
    @Published var isLoading = false
    @Published var error: String?
    
    let availableCurrencies = ["USD", "EUR", "UAH", "GBP", "JPY", "CAD", "AUD", "CNY"]
    private let apiKey = "c1338d80c82bb212d09f626570e5831c"
    private var conversionTask: URLSessionDataTask?
    
    func convert() {
        conversionTask?.cancel()
        
        guard !amount.isEmpty else {
            convertedValue = nil
            error = nil
            return
        }
        
        guard let value = Double(amount), value > 0 else {
            convertedValue = nil
            error = "Please enter a valid positive number"
            return
        }

        isLoading = true
        error = nil
        
        var components = URLComponents(string: "https://api.exchangerate.host/convert")!
        components.queryItems = [
            URLQueryItem(name: "from", value: sourceCurrency),
            URLQueryItem(name: "to", value: targetCurrency),
            URLQueryItem(name: "amount", value: amount),
            URLQueryItem(name: "access_key", value: apiKey)
        ]
        
        guard let url = components.url else {
            self.error = "Invalid URL"
            self.isLoading = false
            return
        }

        conversionTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error as? URLError, error.code == .cancelled {
                    return
                }
                
                if let error = error {
                    self?.error = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self?.error = "Server returned an error"
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    return
                }

                do {
                    let result = try JSONDecoder().decode(ConvertResponse.self, from: data)
                    
                    if !result.success {
                        self?.error = result.error?.info ?? "Conversion failed"
                        return
                    }
                    
                    if let converted = result.result {
                        self?.convertedValue = converted
                    } else {
                        self?.error = "Invalid conversion result"
                    }
                } catch {
                    print("Decoding error:", error)
                    self?.error = "Failed to parse server response"
                }
            }
        }
        conversionTask?.resume()
    }
}

struct ConvertResponse: Codable {
    let success: Bool
    let result: Double?
    let error: ErrorInfo?
    
    struct ErrorInfo: Codable {
        let info: String
    }
}
