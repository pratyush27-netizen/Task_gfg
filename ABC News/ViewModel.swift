//
//  ViewModel.swift
//  ABC News
//
//  Created by PRATYUSH on 26/05/23.
//
import Foundation

struct FeedResponse: Codable {
    let items: [Article]
}

struct Article: Codable, Identifiable {
    let id: String
    let title: String
    let pubDate: String
    let thumbnail: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "guid"
        case title
        case pubDate
        case thumbnail
        case imageUrl = "enclosure"
    }
}

class ABCNewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isRefreshing = false
    
    private var currentPage = 1
    
    func fetchArticles() {
        guard let url = URL(string: "https://api.rss2json.com/v1/api.json?rss_url=http://www.abc.net.au/news/feed/51120/rss.xml") else { return }
        
        isRefreshing = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            if let decodedResponse = try? JSONDecoder().decode(FeedResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.articles = decodedResponse.items
                    self.isRefreshing = false
                }
            }
        }.resume()
    }
    
    func fetchMoreArticles() {
        guard let url = URL(string: "https://api.rss2json.com/v1/api.json?rss_url=http://www.abc.net.au/news/feed/51120/rss.xml&page=\(currentPage + 1)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            if let decodedResponse = try? JSONDecoder().decode(FeedResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.articles.append(contentsOf: decodedResponse.items)
                    self.currentPage += 1
                }
            }
        }.resume()
    }
}
