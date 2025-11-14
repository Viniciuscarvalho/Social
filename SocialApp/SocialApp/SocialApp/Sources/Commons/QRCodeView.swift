import SwiftUI
import CoreImage.CIFilterBuiltins

public struct QRCodeView: View {
    private static let context = CIContext()
    private static let filter = CIFilter.qrCodeGenerator()
    
    private let dataString: String
    private let size: CGFloat
    private let cornerRadius: CGFloat
    
    public init(
        data: String,
        size: CGFloat = 100,
        cornerRadius: CGFloat = 12
    ) {
        self.dataString = data
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        Group {
            if let image = generateQRCode(from: dataString) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: size * 0.35))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: size, height: size)
        .background(Color.white)
        .cornerRadius(cornerRadius)
        .shadow(color: AppColors.cardShadow.opacity(0.08), radius: 6, x: 0, y: 4)
        .accessibilityLabel("QR Code do ingresso")
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        
        QRCodeView.filter.setValue(data, forKey: "inputMessage")
        QRCodeView.filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let outputImage = QRCodeView.filter.outputImage else {
            return nil
        }
        
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = QRCodeView.context.createCGImage(transformed, from: transformed.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview("QR Code") {
    QRCodeView(data: "ticket-12345", size: 140)
        .padding()
        .background(AppColors.backgroundGradient)
        .environment(ThemeManager.shared)
}


