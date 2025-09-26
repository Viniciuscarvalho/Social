import SwiftUI

public struct SectionHeader: View {
    let title: String
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
}
