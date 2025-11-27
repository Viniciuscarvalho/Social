import Foundation
import SwiftUI

public struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(placeholder)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            if isSecure {
                SecureField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.black) // ✅ Texto preto
                    .cornerRadiusCustom(10, corners: .allCorners)
            } else {
                TextField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.black) // ✅ Texto preto
                    .cornerRadiusCustom(10, corners: .allCorners)
                    .autocapitalization(.none)
            }
        }
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadiusCustom(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerCustom(radius: radius, corners: corners))
    }
}

struct RoundedCornerCustom: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
