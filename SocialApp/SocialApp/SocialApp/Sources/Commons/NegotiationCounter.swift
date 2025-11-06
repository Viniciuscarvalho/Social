import SwiftUI

/// Componente para exibir contador de negociações ativas
public struct NegotiationCounter: View {
    let count: Int
    let maxCount: Int
    let isLoading: Bool
    
    public init(count: Int, maxCount: Int = 3, isLoading: Bool = false) {
        self.count = count
        self.maxCount = maxCount
        self.isLoading = isLoading
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 14))
                .foregroundColor(badgeColor)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Text("\(count)/\(maxCount)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(badgeColor)
            }
            
            Text("Negociações")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    private var badgeColor: Color {
        if count >= maxCount {
            return Color.red
        } else if count >= maxCount - 1 {
            return Color.orange
        } else {
            return AppColors.primary
        }
    }
    
    private var backgroundColor: Color {
        if count >= maxCount {
            return Color.red.opacity(0.1)
        } else if count >= maxCount - 1 {
            return Color.orange.opacity(0.1)
        } else {
            return AppColors.primary.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if count >= maxCount {
            return Color.red.opacity(0.3)
        } else if count >= maxCount - 1 {
            return Color.orange.opacity(0.3)
        } else {
            return AppColors.primary.opacity(0.3)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        NegotiationCounter(count: 0, maxCount: 3)
        NegotiationCounter(count: 1, maxCount: 3)
        NegotiationCounter(count: 2, maxCount: 3)
        NegotiationCounter(count: 3, maxCount: 3)
        NegotiationCounter(count: 1, maxCount: 3, isLoading: true)
    }
    .padding()
}




