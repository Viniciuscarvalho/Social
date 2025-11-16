import SwiftUI

/// View de skeleton para loading state
public struct SkeletonView: View {
    let cornerRadius: CGFloat
    @State private var isAnimating = false
    
    public init(cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.2)
                    ],
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating.toggle()
                }
            }
    }
}

/// Skeleton para card de evento
public struct EventCardSkeleton: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            SkeletonView(cornerRadius: 12)
                .frame(height: 180)
            
            // Title
            SkeletonView(cornerRadius: 6)
                .frame(height: 20)
                .frame(maxWidth: .infinity)
            
            // Subtitle
            SkeletonView(cornerRadius: 6)
                .frame(height: 16)
                .frame(maxWidth: 200)
            
            HStack {
                // Date
                SkeletonView(cornerRadius: 6)
                    .frame(width: 80, height: 16)
                
                Spacer()
                
                // Price
                SkeletonView(cornerRadius: 6)
                    .frame(width: 60, height: 16)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

/// Skeleton para card de ticket
public struct TicketCardSkeleton: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            // Image
            SkeletonView(cornerRadius: 12)
                .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 8) {
                // Event name
                SkeletonView(cornerRadius: 6)
                    .frame(height: 18)
                    .frame(maxWidth: .infinity)
                
                // Date
                SkeletonView(cornerRadius: 6)
                    .frame(height: 14)
                    .frame(width: 120)
                
                // Sector
                SkeletonView(cornerRadius: 6)
                    .frame(height: 14)
                    .frame(width: 80)
                
                Spacer()
                
                // Price
                SkeletonView(cornerRadius: 6)
                    .frame(height: 20)
                    .frame(width: 100)
            }
        }
        .frame(height: 120)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

/// Skeleton para perfil de usuário
public struct ProfileHeaderSkeleton: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            // Avatar
            SkeletonView(cornerRadius: 50)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            // Name
            SkeletonView(cornerRadius: 6)
                .frame(width: 150, height: 24)
            
            // Bio
            VStack(spacing: 6) {
                SkeletonView(cornerRadius: 6)
                    .frame(height: 16)
                    .frame(maxWidth: 280)
                
                SkeletonView(cornerRadius: 6)
                    .frame(height: 16)
                    .frame(maxWidth: 200)
            }
            
            // Stats
            HStack(spacing: 40) {
                ForEach(0..<3) { _ in
                    VStack(spacing: 6) {
                        SkeletonView(cornerRadius: 6)
                            .frame(width: 40, height: 20)
                        
                        SkeletonView(cornerRadius: 6)
                            .frame(width: 60, height: 14)
                    }
                }
            }
        }
        .padding(20)
    }
}

/// Skeleton para lista de negociações
public struct NegotiationCardSkeleton: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            // Avatar
            SkeletonView(cornerRadius: 25)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8) {
                // Name
                SkeletonView(cornerRadius: 6)
                    .frame(height: 18)
                    .frame(maxWidth: 150)
                
                // Event
                SkeletonView(cornerRadius: 6)
                    .frame(height: 14)
                    .frame(maxWidth: 200)
                
                // Status
                SkeletonView(cornerRadius: 6)
                    .frame(width: 80, height: 14)
            }
            
            Spacer()
            
            // Price
            SkeletonView(cornerRadius: 6)
                .frame(width: 80, height: 20)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

/// Modifier para adicionar skeleton loading
public struct SkeletonModifier: ViewModifier {
    let isLoading: Bool
    let skeleton: AnyView
    
    public func body(content: Content) -> some View {
        if isLoading {
            skeleton
        } else {
            content
        }
    }
}

extension View {
    /// Adiciona skeleton loading a uma view
    public func skeleton<T: View>(
        isLoading: Bool,
        @ViewBuilder skeleton: () -> T
    ) -> some View {
        modifier(
            SkeletonModifier(
                isLoading: isLoading,
                skeleton: AnyView(skeleton())
            )
        )
    }
}

#Preview("Event Card Skeleton") {
    VStack(spacing: 16) {
        EventCardSkeleton()
        EventCardSkeleton()
    }
    .padding()
    .background(AppColors.background)
}

#Preview("Ticket Card Skeleton") {
    VStack(spacing: 12) {
        TicketCardSkeleton()
        TicketCardSkeleton()
        TicketCardSkeleton()
    }
    .padding()
    .background(AppColors.background)
}

#Preview("Profile Skeleton") {
    ProfileHeaderSkeleton()
        .background(AppColors.background)
}

#Preview("Negotiation Skeleton") {
    VStack(spacing: 12) {
        NegotiationCardSkeleton()
        NegotiationCardSkeleton()
    }
    .padding()
    .background(AppColors.background)
}











