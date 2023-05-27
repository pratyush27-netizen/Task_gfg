//
//  ContentView.swift
//  ABC News
//
//  Created by PRATYUSH on 26/05/23.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ABCNewsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.articles, id: \.id) { article in
                ArticleRow(article: article)
            }
            .navigationBarTitle("ABC News")
            .onAppear {
                viewModel.fetchArticles()
            }
            .modifier(PullToRefreshModifier(isRefreshing: $viewModel.isRefreshing) {
                viewModel.fetchArticles()
            })
        }
    }
}

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = article.imageUrl {
                RemoteImage(url: imageUrl)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            } else if let thumbnail = article.thumbnail {
                RemoteImage(url: thumbnail)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            }
            Text(article.title)
                .font(.headline)
            Text(article.pubDate)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct RemoteImage: View {
    let url: String
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onAppear {
                    imageLoader.loadImage(from: url)
                }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let loadedImage = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image = loadedImage
            }
        }.resume()
    }
}

struct PullToRefreshModifier: ViewModifier {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isRefreshing {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.7))
                        .onAppear {
                            onRefresh()
                        }
                    }
                }
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

