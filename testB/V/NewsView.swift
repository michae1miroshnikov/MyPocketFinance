import SwiftUI

struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var lastRefreshTime = Date()
    
    private var backgroundColor: Color {
        Color(.systemBackground)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.newsItems.isEmpty {
                loadingView
            } else if let error = viewModel.errorMessage, viewModel.newsItems.isEmpty {
                errorView(error)
            } else {
                newsListView
            }
        }
        .navigationTitle("Market News")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refresh()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            if shouldRefresh() {
                viewModel.fetchNewsSentiment()
            }
        }
        .refreshable {
            viewModel.refresh()
            lastRefreshTime = Date()
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("Loading market news...")
                .padding()
            Text("Please wait while we fetch the latest updates")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Couldn't load news")
                .font(.headline)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Try Again") {
                viewModel.refresh()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var newsListView: some View {
        List {
            ForEach(viewModel.newsItems) { item in
                newsItemView(item)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading && !viewModel.newsItems.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(backgroundColor.opacity(0.5))
            }
        }
    }
    
    private func newsItemView(_ item: NewsItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let source = item.source, !source.isEmpty {
                        Text(source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                sentimentBadge(item.sentiment)
            }
            
            if let summary = item.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            if let urlString = item.url, !urlString.isEmpty, let url = URL(string: urlString) {
                HStack {
                    Link(destination: url) {
                        HStack {
                            Text("Read full article")
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.caption)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        shareNewsItem(item)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func shareNewsItem(_ item: NewsItem) {
        var shareContent = item.title
        shareContent += "\n\n"
        
        if let summary = item.summary, !summary.isEmpty {
            shareContent += "\(summary)\n\n"
        }
        
        if let source = item.source, !source.isEmpty {
            shareContent += "Source: \(source)\n"
        }
        
        if let urlString = item.url, !urlString.isEmpty {
            shareContent += urlString
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    private func sentimentBadge(_ sentiment: String) -> some View {
        Text(sentiment)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(sentimentColor(sentiment).opacity(0.2))
            .foregroundColor(sentimentColor(sentiment))
            .cornerRadius(4)
    }
    
    private func sentimentColor(_ sentiment: String) -> Color {
        let lowercased = sentiment.lowercased()
        if lowercased.contains("bullish") {
            return .green
        } else if lowercased.contains("bearish") {
            return .red
        } else {
            return .gray
        }
    }
    
    private func shouldRefresh() -> Bool {
        viewModel.newsItems.isEmpty || lastRefreshTime.timeIntervalSinceNow < -300
    }
}

// Add this extension if you need to use systemBackground elsewhere in your project
extension Color {
    static var systemBackground: Color {
        Color(.systemBackground)
    }
}
