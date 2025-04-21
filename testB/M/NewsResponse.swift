import Foundation

struct NewsResponse: Codable {
    let feed: [NewsItem]?
    let note: String?
    let information: String?
    
    enum CodingKeys: String, CodingKey {
        case feed = "feed"
        case note = "Note"
        case information = "Information"
    }
}

struct NewsItem: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    let url: String?
    let summary: String?
    let bannerImage: String?
    let sentiment: String
    let source: String?
    let timePublished: String?
    
    enum CodingKeys: String, CodingKey {
        case title, url, summary, source
        case bannerImage = "banner_image"
        case sentiment = "overall_sentiment_label"
        case timePublished = "time_published"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        bannerImage = try container.decodeIfPresent(String.self, forKey: .bannerImage)
        sentiment = try container.decodeIfPresent(String.self, forKey: .sentiment) ?? "Neutral"
        source = try container.decodeIfPresent(String.self, forKey: .source)
        timePublished = try container.decodeIfPresent(String.self, forKey: .timePublished)
    }
    
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        lhs.id == rhs.id
    }
}
