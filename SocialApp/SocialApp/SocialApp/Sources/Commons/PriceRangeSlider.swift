import SwiftUI

/// Componente de slider de faixa de preço com gradiente
public struct PriceRangeSlider: View {
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    let range: ClosedRange<Double>
    
    public init(
        minPrice: Binding<Double>,
        maxPrice: Binding<Double>,
        range: ClosedRange<Double> = 0...1000
    ) {
        self._minPrice = minPrice
        self._maxPrice = maxPrice
        self.range = range
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TICKET PRICE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("$\(Int(minPrice)) - $\(Int(maxPrice))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            // Slider customizado com dois controles
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    
                    // Active range track com gradiente
                    let minOffset = CGFloat((minPrice - range.lowerBound) / (range.upperBound - range.lowerBound))
                    let maxOffset = CGFloat((maxPrice - range.lowerBound) / (range.upperBound - range.lowerBound))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * (maxOffset - minOffset),
                            height: 4
                        )
                        .offset(x: geometry.size.width * minOffset)
                    
                    // Min thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .offset(x: geometry.size.width * minOffset - 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(value.location.x / geometry.size.width)
                                    minPrice = min(max(range.lowerBound, newValue), maxPrice - 10)
                                }
                        )
                    
                    // Max thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        .overlay(
                            Circle()
                                .stroke(Color.purple, lineWidth: 2)
                        )
                        .offset(x: geometry.size.width * maxOffset - 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(value.location.x / geometry.size.width)
                                    maxPrice = min(max(minPrice + 10, newValue), range.upperBound)
                                }
                        )
                }
            }
            .frame(height: 24)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var minPrice: Double = 50
        @State private var maxPrice: Double = 90
        
        var body: some View {
            VStack {
                PriceRangeSlider(
                    minPrice: $minPrice,
                    maxPrice: $maxPrice,
                    range: 0...200
                )
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}


