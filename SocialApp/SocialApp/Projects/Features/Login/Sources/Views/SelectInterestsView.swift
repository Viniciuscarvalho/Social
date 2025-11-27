import SwiftUI
import DesignSystem

struct SelectInterestsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedInterests: Set<String> = []
    
    let onInterestsSelected: ([String]) -> Void
    
    let interests = [
        ("🏢", "Business"),
        ("🎨", "Arts"),
        ("🎵", "Music"),
        ("❤️", "Health"),
        ("🍔", "Food & Drink"),
        ("🎮", "Gaming"),
        ("🎬", "Film & Media"),
        ("👨‍👩‍👧‍👦", "Family & Kids"),
        ("🎭", "Theatre & Performing Arts"),
        ("❤️‍🔥", "Community & Charity"),
        ("🐾", "Pet & Animal Events"),
        ("📚", "Books & Literature")
    ]
    
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
                    VStack(spacing: 12) {
                        let columns: [GridItem] = [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(interests, id: \.1) { emoji, interest in
                                InterestChip(
                                    emoji: emoji,
                                    title: interest,
                                    isSelected: selectedInterests.contains(interest),
                                    action: {
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else {
                                            selectedInterests.insert(interest)
                                        }
                                    }
                                )
                            }
                        }
                    }
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
                        .background(DSColors.primary)
                        .cornerRadius(12)
                }
                .disabled(selectedInterests.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct InterestChip: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 32))
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isSelected ? AppColors.primary.opacity(0.1) : Color(.systemGray6))
            .border(
                isSelected ? DSColors.primary : Color.clear,
                width: 2
            )
            .cornerRadius(12)
        }
    }
}

#Preview {
    SelectInterestsView { interests in
    }
}

