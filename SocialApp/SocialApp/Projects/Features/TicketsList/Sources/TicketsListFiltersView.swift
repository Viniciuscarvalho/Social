import SwiftUI
import ComposableArchitecture
import DesignSystem

/// Filtros de categoria da lista de tickets
struct TicketsListFiltersView: View {
    @Bindable var store: StoreOf<TicketsListFeature>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                categoryFilterButton(title: "All Tickets", isSelected: store.selectedFilter.ticketType == nil) {
                    var filter = store.selectedFilter
                    filter.ticketType = nil
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "VIP", isSelected: store.selectedFilter.ticketType == .vip) {
                    var filter = store.selectedFilter
                    filter.ticketType = .vip
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "General", isSelected: store.selectedFilter.ticketType == .general) {
                    var filter = store.selectedFilter
                    filter.ticketType = .general
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Early Bird", isSelected: store.selectedFilter.ticketType == .earlyBird) {
                    var filter = store.selectedFilter
                    filter.ticketType = .earlyBird
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Group", isSelected: store.selectedFilter.ticketType == .group) {
                    var filter = store.selectedFilter
                    filter.ticketType = .group
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Student", isSelected: store.selectedFilter.ticketType == .student) {
                    var filter = store.selectedFilter
                    filter.ticketType = .student
                    store.send(.filterChanged(filter))
                }
                
                categoryFilterButton(title: "Senior", isSelected: store.selectedFilter.ticketType == .senior) {
                    var filter = store.selectedFilter
                    filter.ticketType = .senior
                    store.send(.filterChanged(filter))
                }
            }
            .padding(.horizontal, DSSpacing.m)
        }
        .padding(.bottom, DSSpacing.l)
    }
    
    @ViewBuilder
    private func categoryFilterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.footnote(weight: .semibold))
                .foregroundColor(isSelected ? .white : DSColors.textPrimary)
                .padding(.horizontal, DSSpacing.m)
                .padding(.vertical, DSSpacing.xs)
                .background(isSelected ? DSColors.primary : DSColors.backgroundSecondary)
                .dsCornerRadius(DSRadius.buttonSmall)
        }
        .dsTapFeedback()
    }
}

