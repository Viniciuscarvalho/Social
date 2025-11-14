import SwiftUI

struct SelectInterestsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedInterests: Set<String> = []
    
    let onInterestsSelected: ([String]) -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select your Interests")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
                
                // Interests Grid
                ScrollView {
                    InterestSelectionView(selectedInterests: $selectedInterests)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    onInterestsSelected(Array(selectedInterests))
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
                .disabled(selectedInterests.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    SelectInterestsView { interests in
    }
}

