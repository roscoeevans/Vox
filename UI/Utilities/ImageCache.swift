import SwiftUI
import Combine

// MARK: - Image Cache Manager
class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSURL, UIImage>()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        cache.countLimit = 100 // Limit number of images
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func cache(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL, cost: image.jpegData(compressionQuality: 1.0)?.count ?? 0)
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let cachedImage = image(for: url) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .catch { _ in Just(nil) }
            .handleEvents(receiveOutput: { [weak self] image in
                if let image = image {
                    self?.cache(image, for: url)
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Cached Async Image View
struct CachedAsyncImage: View {
    let url: URL
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let cacheManager = ImageCacheManager.shared
        
        // Check cache first
        if let cachedImage = cacheManager.image(for: url) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // Load from network
        cancellable = cacheManager.loadImage(from: url)
            .sink { loadedImage in
                self.image = loadedImage
                self.isLoading = false
            }
    }
} 