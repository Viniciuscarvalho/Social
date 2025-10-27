import SwiftUI

/// Barra de busca persistente no topo das telas
public struct SearchBarView: View {
    @Binding var searchText: String
    let placeholder: String
    let onFilterTap: (() -> Void)?
    
    public init(
        searchText: Binding<String>,
        placeholder: String = "Search...",
        onFilterTap: (() -> Void)? = nil
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
        self.onFilterTap = onFilterTap
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $searchText)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // Filter button (se fornecido)
            if let onFilterTap = onFilterTap {
                Button(action: onFilterTap) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var searchText = ""
        
        var body: some View {
            VStack {
                SearchBarView(
                    searchText: $searchText,
                    placeholder: "Search...",
                    onFilterTap: {
                        print("Filter tapped")
                    }
                )
                .padding()
                
                Spacer()
            }
        }
    }
    
    return PreviewWrapper()
}


