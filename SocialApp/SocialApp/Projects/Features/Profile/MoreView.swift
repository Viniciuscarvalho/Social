import SwiftUI

struct MoreView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    menuSection
                    illustrationSection
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                }
            }
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                // TODO: Hook into delete account flow
                print("🗑️ Delete account confirmed")
            }
        } message: {
            Text("Tem certeza de que deseja excluir sua conta? Esta ação não pode ser desfeita.")
        }
    }
    
    private var menuSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                FAQsView()
            } label: {
                menuRow(
                    icon: "questionmark.circle.fill",
                    iconColor: AppColors.primary,
                    title: "FAQs"
                )
            }
            .buttonStyle(.plain)
            
            Divider().padding(.leading, 60)
            
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                menuRow(
                    icon: "hand.raised.fill",
                    iconColor: AppColors.secondary,
                    title: "Privacy Policy"
                )
            }
            .buttonStyle(.plain)
            
            Divider().padding(.leading, 60)
            
            NavigationLink {
                ContactUsView(openURL: openURL)
            } label: {
                menuRow(
                    icon: "envelope.fill",
                    iconColor: AppColors.accentBlue,
                    title: "Contact Us"
                )
            }
            .buttonStyle(.plain)
            
            Divider().padding(.leading, 60)
            
            Button {
                showingDeleteAlert = true
            } label: {
                menuRow(
                    icon: "trash.fill",
                    iconColor: AppColors.error,
                    title: "Delete Account",
                    isDestructive: true,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.12), radius: 12, x: 0, y: 8)
        )
    }
    
    private func menuRow(
        icon: String,
        iconColor: Color,
        title: String,
        isDestructive: Bool = false,
        showsChevron: Bool = true
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isDestructive ? AppColors.error : iconColor)
                .frame(width: 36, height: 36)
                .background((isDestructive ? AppColors.error : iconColor).opacity(0.15))
                .clipShape(Circle())
            
            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(isDestructive ? AppColors.error : AppColors.primaryText)
            
            Spacer()
            
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var illustrationSection: some View {
        Image("empty_events")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .accessibilityHidden(true)
    }
}

// MARK: - Placeholder Views

private struct FAQsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppColors.primary)
                
                Text("FAQs")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Em breve você encontrará aqui as dúvidas mais frequentes sobre o SocialApp.")
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
        }
        .background(AppColors.backgroundGradient.ignoresSafeArea())
        .navigationTitle("FAQs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title2.weight(.bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("""
Sua privacidade é importante para nós. Utilizamos seus dados apenas para fornecer uma experiência personalizada no SocialApp. Nenhuma informação sensível é compartilhada sem o seu consentimento.

• Coletamos dados básicos do perfil.
• Utilizamos cookies para melhorar recomendações.
• Você pode solicitar remoção completa a qualquer momento.
""")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
            }
            .padding(24)
        }
        .background(AppColors.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ContactUsView: View {
    @Environment(\.openURL) private var openURLDefault
    private let openURLAction: OpenURLAction?
    
    init(openURL: OpenURLAction? = nil) {
        self.openURLAction = openURL
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColors.accentBlue)
            
            VStack(spacing: 6) {
                Text("Contact Us")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(AppColors.primaryText)
                Text("support@socialapp.com")
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Button {
                let url = URL(string: "mailto:support@socialapp.com")!
                if let openURLAction {
                    openURLAction(url)
                } else {
                    openURLDefault(url)
                }
            } label: {
                Text("Enviar Email")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding()
        .background(AppColors.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Contact Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}


