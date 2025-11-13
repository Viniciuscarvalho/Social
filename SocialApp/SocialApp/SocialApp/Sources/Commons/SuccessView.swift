import SwiftUI

/// View reutilizável para exibir telas de sucesso com ícone, título, mensagem e botão de ação
public struct SuccessView: View {
  let icon: String
  let iconColor: Color
  let useCustomIcon: Bool
  let title: String
  let message: String
  let buttonTitle: String
  let buttonAction: () -> Void
  
  public init(
    icon: String = "checkmark.circle.fill",
    iconColor: Color = .green,
    useCustomIcon: Bool = false,
    title: String,
    message: String,
    buttonTitle: String,
    buttonAction: @escaping () -> Void
  ) {
    self.icon = icon
    self.iconColor = iconColor
    self.useCustomIcon = useCustomIcon
    self.title = title
    self.message = message
    self.buttonTitle = buttonTitle
    self.buttonAction = buttonAction
  }
  
  public var body: some View {
    VStack(spacing: 24) {
      Spacer()
      
      // Ícone circular
      ZStack {
        Circle()
          .fill(iconColor.opacity(0.1))
          .frame(width: 100, height: 100)
        
        if useCustomIcon {
          Image(icon, bundle: Bundle.main)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .foregroundColor(iconColor)
        } else {
          Image(systemName: icon)
            .font(.system(size: 48, weight: .semibold))
            .foregroundColor(iconColor)
        }
      }
      
      // Título e mensagem
      VStack(spacing: 8) {
        Text(title)
          .font(.system(size: 28, weight: .bold))
          .foregroundColor(AppColors.primaryText)
        
        Text(message)
          .font(.system(size: 16))
          .foregroundColor(AppColors.secondaryText)
          .multilineTextAlignment(.center)
      }
      
      Spacer()
      
      // Botão de ação
      Button(action: buttonAction) {
        Text(buttonTitle)
          .font(.system(size: 16, weight: .semibold))
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(AppColors.primary)
          .cornerRadius(12)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 40)
  }
}

#Preview("Success View - Default") {
  SuccessView(
    title: "Bem-sucedido",
    message: "Sua ação foi concluída com sucesso!",
    buttonTitle: "Concluir",
    buttonAction: {}
  )
  .background(AppColors.background)
}

#Preview("Success View - Custom Icon") {
  SuccessView(
    icon: "checkmark.circle.fill",
    iconColor: .green,
    title: "Anunciar Ingresso Está Pronto!",
    message: "Os detalhes do seu ingresso estão configurados. Revise e publique para disponibilizar para compradores.",
    buttonTitle: "Confirmar & Publicar",
    buttonAction: {}
  )
  .background(AppColors.background)
}

#Preview("Success View - Password Reset") {
  SuccessView(
    icon: "checkmark.circle.fill",
    iconColor: .green,
    title: "Successful",
    message: "Your new password has been set successfully!",
    buttonTitle: "Done",
    buttonAction: {}
  )
  .background(AppColors.background)
}

