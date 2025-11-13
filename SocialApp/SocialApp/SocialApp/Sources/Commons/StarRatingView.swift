import SwiftUI

/// Componente de avaliação com estrelas (interativo ou read-only)
public struct StarRatingView: View {
    @Binding var rating: Int
    let maxRating: Int
    let size: CGFloat
    let interactive: Bool
    let spacing: CGFloat
    
    public init(
        rating: Binding<Int>,
        maxRating: Int = 5,
        size: CGFloat = 32,
        interactive: Bool = true,
        spacing: CGFloat = 8
    ) {
        self._rating = rating
        self.maxRating = maxRating
        self.size = size
        self.interactive = interactive
        self.spacing = spacing
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                starView(for: index)
                    .onTapGesture {
                        guard interactive else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            rating = index
                        }
                    }
            }
        }
    }
    
    private func starView(for index: Int) -> some View {
        Image(systemName: index <= rating ? "star.fill" : "star")
            .font(.system(size: size))
            .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.3))
            .scaleEffect(index == rating && interactive ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rating)
    }
}

/// Versão read-only para exibir ratings
public struct StarRatingDisplayView: View {
    let rating: Double
    let maxRating: Int
    let size: CGFloat
    let spacing: CGFloat
    let showNumber: Bool
    
    public init(
        rating: Double,
        maxRating: Int = 5,
        size: CGFloat = 16,
        spacing: CGFloat = 4,
        showNumber: Bool = true
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.size = size
        self.spacing = spacing
        self.showNumber = showNumber
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                starView(for: index)
            }
            
            if showNumber {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: size * 0.75, weight: .semibold))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
    
    private func starView(for index: Int) -> some View {
        let fillPercentage = min(max(rating - Double(index - 1), 0), 1)
        
        return ZStack {
            Image(systemName: "star")
                .font(.system(size: size))
                .foregroundColor(.gray.opacity(0.3))
            
            if fillPercentage > 0 {
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundColor(.yellow)
                    .mask(
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: geometry.size.width * fillPercentage)
                        }
                    )
            }
        }
    }
}

#Preview("Interactive Rating") {
    VStack(spacing: 40) {
        // Small
        StarRatingView(
            rating: .constant(0),
            size: 24,
            spacing: 6
        )
        
        // Medium
        StarRatingView(
            rating: .constant(3),
            size: 32,
            spacing: 8
        )
        
        // Large
        StarRatingView(
            rating: .constant(5),
            size: 48,
            spacing: 12
        )
    }
    .padding()
}

#Preview("Display Rating") {
    VStack(spacing: 20) {
        StarRatingDisplayView(rating: 4.5)
        StarRatingDisplayView(rating: 3.7)
        StarRatingDisplayView(rating: 5.0)
        StarRatingDisplayView(rating: 2.3)
    }
    .padding()
}









