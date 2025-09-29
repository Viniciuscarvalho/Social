import SwiftUI

public struct ThemeToggleView: View {
    @Environment(ThemeManager.self) private var themeManager
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(AppColors.primary)
                Text("Aparência")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                themeOption(title: "Automático", systemImage: "circle.righthalf.filled", isSelected: themeManager.colorScheme == nil) {
                    themeManager.colorScheme = nil
                }
                
                themeOption(title: "Claro", systemImage: "sun.max.fill", isSelected: themeManager.colorScheme == .light) {
                    themeManager.colorScheme = .light
                }
                
                themeOption(title: "Escuro", systemImage: "moon.fill", isSelected: themeManager.colorScheme == .dark) {
                    themeManager.colorScheme = .dark
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func themeOption(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.secondaryText)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? AppColors.primary.opacity(0.3) : AppColors.separator.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemeToggleView()
        .padding()
        .background(AppColors.background)
        .environment(ThemeManager.shared)
}