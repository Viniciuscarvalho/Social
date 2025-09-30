import SwiftUI

public struct ProfilePlaceholderView: View {
    public init() {}
    
    public var body: some View {
        ProfileView()
    }
}

#Preview {
    ProfilePlaceholderView()
        .environment(ThemeManager.shared)
}