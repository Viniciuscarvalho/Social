import SwiftUI

public enum InterestCategory: String, CaseIterable, Codable, Identifiable {
    case business = "Business"
    case arts = "Arts"
    case music = "Music"
    case health = "Health"
    case foodDrink = "Food & Drink"
    case gaming = "Gaming"
    case travelAdventure = "Travel & Adventure"
    case filmMedia = "Film & Media"
    case familyKids = "Family & Kids"
    case theatrePerforming = "Theatre & Performing Arts"
    case communityCharity = "Community & Charity"
    case shopping = "Shopping"
    case petEvents = "Pet & Animal Events"
    case booksLiterature = "Books & Literature"
    
    public var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .business: return "briefcase.fill"
        case .arts: return "paintpalette.fill"
        case .music: return "music.note"
        case .health: return "heart.fill"
        case .foodDrink: return "fork.knife"
        case .gaming: return "gamecontroller.fill"
        case .travelAdventure: return "airplane"
        case .filmMedia: return "film.fill"
        case .familyKids: return "figure.2.and.child.holdinghands"
        case .theatrePerforming: return "theatermasks.fill"
        case .communityCharity: return "person.3.fill"
        case .shopping: return "bag.fill"
        case .petEvents: return "pawprint.fill"
        case .booksLiterature: return "book.fill"
        }
    }
    
}

public struct InterestChip: View {
    let interest: InterestCategory
    let isSelected: Bool
    let action: () -> Void
    
    public init(interest: InterestCategory, isSelected: Bool, action: @escaping () -> Void) {
        self.interest = interest
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: interest.iconName)
                    .font(.system(size: 14, weight: .semibold))
                Text(interest.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? AppColors.primary : AppColors.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? AppColors.primary.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isSelected ? AppColors.primary : AppColors.borderLight, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

public struct InterestSelectionView: View {
    @Binding private var selectedInterests: Set<String>
    private let columns: [GridItem]
    
    public init(selectedInterests: Binding<Set<String>>, columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]) {
        self._selectedInterests = selectedInterests
        self.columns = columns
    }
    
    public var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(InterestCategory.allCases) { category in
                InterestChip(
                    interest: category,
                    isSelected: selectedInterests.contains(category.rawValue)
                ) {
                    toggle(category)
                }
            }
        }
    }
    
    private func toggle(_ category: InterestCategory) {
        if selectedInterests.contains(category.rawValue) {
            selectedInterests.remove(category.rawValue)
        } else {
            selectedInterests.insert(category.rawValue)
        }
    }
}

#Preview("Interest Chips") {
    StatefulPreviewWrapper(Set<String>([InterestCategory.music.rawValue, InterestCategory.booksLiterature.rawValue])) { binding in
        ScrollView {
            InterestSelectionView(selectedInterests: binding)
                .padding()
        }
    }
    .environment(ThemeManager.shared)
}

// MARK: - Preview Helpers

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content
    
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}

