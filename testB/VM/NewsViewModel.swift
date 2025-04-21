import Foundation
import Combine

class NewsViewModel: ObservableObject {
    @Published var newsItems: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "Q83XQIYI6CYUPF8I" // Replace with your actual API key
    private var cancellables = Set<AnyCancellable>()
    
    func fetchNewsSentiment() {
        isLoading = true
        errorMessage = nil
        
        let tickers = "AAPL,MSFT,GOOG,TSLA"
        let urlString = "https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers=\(tickers)&apikey=\(apiKey)"
        
        print("Fetching from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] response in
                self?.isLoading = false
                if let items = response.feed {
                    self?.newsItems = items
                    if items.isEmpty {
                        self?.errorMessage = "No news items found"
                    }
                } else if let note = response.note {
                    self?.errorMessage = note
                } else {
                    self?.errorMessage = "Unexpected response format"
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection"
            case .timedOut:
                errorMessage = "Request timed out"
            default:
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } else if let decodingError = error as? DecodingError {
            errorMessage = "Failed to parse response: \(decodingError.localizedDescription)"
            print("Decoding error details:", decodingError)
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    func refresh() {
        fetchNewsSentiment()
    }
}

struct APIErrorResponse: Codable {
    let note: String?
    let information: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case note = "Note"
        case information = "Information"
        case message = "Message"
    }
}
