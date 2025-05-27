import SwiftUI
// ... existing code ...
// Place ImageGalleryView struct here.
// ... existing code ...

private struct ImageGalleryView: View {
    let images: [BSEmbedImage]
    let initialIndex: Int
    @Binding var isPresented: Bool
    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var retryCounts: [Int: Int] = [:]
    @State private var useFullSize: [Int: Bool] = [:]
    let sourceFrame: CGRect
    
    init(images: [BSEmbedImage], initialIndex: Int, isPresented: Binding<Bool>, sourceFrame: CGRect) {
        self.images = images
        self.initialIndex = initialIndex
        self._isPresented = isPresented
        self._currentIndex = State(initialValue: initialIndex)
        self.sourceFrame = sourceFrame
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.element.image?.ref?.link) { index, image in
                    GalleryImageView(
                        image: image,
                        index: index,
                        scale: $scale,
                        lastScale: $lastScale,
                        offset: $offset,
                        lastOffset: $lastOffset,
                        retryCounts: $retryCounts,
                        useFullSize: $useFullSize
                    )
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
} 