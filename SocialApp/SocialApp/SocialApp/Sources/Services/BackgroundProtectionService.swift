import SwiftUI
import UIKit

/// Serviço para ofuscar a tela quando o app vai para background,
/// protegendo informações sensíveis de serem capturadas no app switcher
public class BackgroundProtectionService: ObservableObject {
    public static let shared = BackgroundProtectionService()
    
    @Published public var isProtectionEnabled: Bool = true
    
    private var blurView: UIVisualEffectView?
    private var logoView: UIImageView?
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    
    /// Ativa a proteção de background
    public func enableProtection() {
        isProtectionEnabled = true
        print("🔒 Proteção de background ativada")
    }
    
    /// Desativa a proteção de background
    public func disableProtection() {
        isProtectionEnabled = false
        print("🔓 Proteção de background desativada")
    }
    
    // MARK: - Private Methods
    
    @objc private func applicationWillResignActive() {
        guard isProtectionEnabled else { return }
        showProtectionView()
    }
    
    @objc private func applicationDidBecomeActive() {
        hideProtectionView()
    }
    
    private func showProtectionView() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("❌ Não foi possível obter a window para proteção")
            return
        }
        
        // Criar blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = window.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 9999 // Tag para identificar e remover depois
        
        // Criar logo/ícone do app
        let logoView = UIImageView()
        logoView.contentMode = .scaleAspectFit
        logoView.tag = 9998
        
        // Tentar carregar o ícone do app
        if let appIcon = UIImage(named: "AppIcon") ?? UIImage(systemName: "lock.shield.fill") {
            logoView.image = appIcon
            logoView.tintColor = .systemBlue
        }
        
        // Configurar layout do logo
        logoView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(logoView)
        
        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 100),
            logoView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Adicionar label "SocialApp" ou nome do app
        let appNameLabel = UILabel()
        appNameLabel.text = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "SocialApp"
        appNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        appNameLabel.textColor = .label
        appNameLabel.textAlignment = .center
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.tag = 9997
        
        blurView.contentView.addSubview(appNameLabel)
        
        NSLayoutConstraint.activate([
            appNameLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 20),
            appNameLabel.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            appNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: blurView.leadingAnchor, constant: 40),
            appNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: blurView.trailingAnchor, constant: -40)
        ])
        
        // Adicionar à window
        window.addSubview(blurView)
        
        self.blurView = blurView
        self.logoView = logoView
        
        print("🔒 Proteção de tela ativada")
    }
    
    private func hideProtectionView() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // Remover views com animação
        UIView.animate(withDuration: 0.2, animations: {
            window.viewWithTag(9999)?.alpha = 0
        }) { _ in
            window.viewWithTag(9999)?.removeFromSuperview()
            window.viewWithTag(9998)?.removeFromSuperview()
            window.viewWithTag(9997)?.removeFromSuperview()
        }
        
        blurView = nil
        logoView = nil
        
        print("🔓 Proteção de tela removida")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - SwiftUI View Modifier

public struct BackgroundProtectionModifier: ViewModifier {
    @StateObject private var protectionService = BackgroundProtectionService.shared
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                protectionService.enableProtection()
            }
    }
}

extension View {
    /// Adiciona proteção de background à view
    public func backgroundProtection() -> some View {
        modifier(BackgroundProtectionModifier())
    }
}

// MARK: - Dependency Key

import ComposableArchitecture

extension BackgroundProtectionService: TestDependencyKey {
    public static var testValue: BackgroundProtectionService {
        return BackgroundProtectionService.shared
    }
}

extension DependencyValues {
    public var backgroundProtection: BackgroundProtectionService {
        get { self[BackgroundProtectionService.self] }
        set { self[BackgroundProtectionService.self] = newValue }
    }
}











