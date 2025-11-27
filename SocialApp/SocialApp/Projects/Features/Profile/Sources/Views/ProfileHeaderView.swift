import SwiftUI
import ComposableArchitecture
import DesignSystem

/// Header do perfil com avatar, nome e botão de editar
struct ProfileHeaderView: View {
    let user: User?
    let onEditTapped: () -> Void
    let onChangeImageTapped: () -> Void
    
    var body: some View {
        if let user = user {
            DSCard {
                HStack(spacing: DSSpacing.m) {
                    // Avatar
                    Button(action: onChangeImageTapped) {
                        ZStack(alignment: .bottomTrailing) {
                            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(DSColors.primary)
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(DSColors.primary)
                                .clipShape(Circle())
                        }
                    }
                    
                    // Nome e email
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(user.name)
                            .font(DSTypography.headline())
                            .foregroundColor(DSColors.textPrimary)
                        
                        if let email = user.email {
                            Text(email)
                                .font(DSTypography.subheadline())
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Editar
                    Button(action: onEditTapped) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(DSColors.primary)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Editar perfil")
                }
            }
            .dsEnterAnimation(isVisible: true)
        } else {
            VStack(spacing: DSSpacing.sm) {
                Circle()
                    .fill(DSColors.cardBackground.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Text("Carregando perfil...")
                    .font(DSTypography.subheadline())
                    .foregroundColor(DSColors.textSecondary)
            }
            .padding(.vertical, DSSpacing.m)
        }
    }
}

