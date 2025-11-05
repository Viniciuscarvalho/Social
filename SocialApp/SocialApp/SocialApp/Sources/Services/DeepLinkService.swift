import Foundation
import UIKit

/// Serviço para abrir deep links de apps externos (WhatsApp, Telegram, Email)
public class DeepLinkService {
    public static let shared = DeepLinkService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Abre o WhatsApp com um número de telefone
    /// - Parameters:
    ///   - phoneNumber: Número de telefone no formato internacional (+5511999999999)
    ///   - message: Mensagem pré-preenchida (opcional)
    /// - Returns: `true` se conseguiu abrir o WhatsApp
    @discardableResult
    public func openWhatsApp(phoneNumber: String, message: String? = nil) -> Bool {
        // Remove caracteres não numéricos e +
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        // Cria a URL do WhatsApp
        var urlString = "https://wa.me/\(cleanNumber)"
        
        if let message = message?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "?text=\(message)"
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida do WhatsApp: \(urlString)")
            return false
        }
        
        print("📱 Abrindo WhatsApp: \(cleanNumber)")
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ WhatsApp aberto com sucesso")
                } else {
                    print("❌ Falha ao abrir WhatsApp")
                }
            }
            return true
        } else {
            print("❌ WhatsApp não está instalado")
            return false
        }
    }
    
    /// Abre o Telegram com um username
    /// - Parameters:
    ///   - username: Username do Telegram (sem @)
    ///   - message: Mensagem pré-preenchida (opcional)
    /// - Returns: `true` se conseguiu abrir o Telegram
    @discardableResult
    public func openTelegram(username: String, message: String? = nil) -> Bool {
        let cleanUsername = username.replacingOccurrences(of: "@", with: "")
        
        var urlString = "tg://resolve?domain=\(cleanUsername)"
        
        if let message = message?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "&text=\(message)"
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida do Telegram: \(urlString)")
            return false
        }
        
        print("📱 Abrindo Telegram: @\(cleanUsername)")
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ Telegram aberto com sucesso")
                } else {
                    print("❌ Falha ao abrir Telegram")
                }
            }
            return true
        } else {
            print("❌ Telegram não está instalado")
            return false
        }
    }
    
    /// Abre o app de Email com destinatário e assunto pré-preenchidos
    /// - Parameters:
    ///   - email: Endereço de email do destinatário
    ///   - subject: Assunto do email (opcional)
    ///   - body: Corpo do email (opcional)
    /// - Returns: `true` se conseguiu abrir o app de email
    @discardableResult
    public func openEmail(email: String, subject: String? = nil, body: String? = nil) -> Bool {
        var components = URLComponents(string: "mailto:\(email)")
        
        var queryItems: [URLQueryItem] = []
        
        if let subject = subject {
            queryItems.append(URLQueryItem(name: "subject", value: subject))
        }
        
        if let body = body {
            queryItems.append(URLQueryItem(name: "body", value: body))
        }
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        guard let url = components?.url else {
            print("❌ URL inválida de email: \(email)")
            return false
        }
        
        print("📧 Abrindo email: \(email)")
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ App de email aberto com sucesso")
                } else {
                    print("❌ Falha ao abrir app de email")
                }
            }
            return true
        } else {
            print("❌ Não foi possível abrir o app de email")
            return false
        }
    }
    
    /// Faz uma ligação telefônica
    /// - Parameter phoneNumber: Número de telefone
    /// - Returns: `true` se conseguiu iniciar a ligação
    @discardableResult
    public func makePhoneCall(phoneNumber: String) -> Bool {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        guard let url = URL(string: "tel://\(cleanNumber)") else {
            print("❌ Número de telefone inválido: \(cleanNumber)")
            return false
        }
        
        print("📞 Ligando para: \(cleanNumber)")
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ Ligação iniciada")
                } else {
                    print("❌ Falha ao iniciar ligação")
                }
            }
            return true
        } else {
            print("❌ Não é possível fazer ligações neste dispositivo")
            return false
        }
    }
    
    /// Envia SMS
    /// - Parameters:
    ///   - phoneNumber: Número de telefone
    ///   - message: Mensagem do SMS (opcional)
    /// - Returns: `true` se conseguiu abrir o app de SMS
    @discardableResult
    public func sendSMS(phoneNumber: String, message: String? = nil) -> Bool {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        var urlString = "sms:\(cleanNumber)"
        
        if let message = message?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "&body=\(message)"
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida de SMS: \(urlString)")
            return false
        }
        
        print("💬 Abrindo SMS: \(cleanNumber)")
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ App de SMS aberto")
                } else {
                    print("❌ Falha ao abrir app de SMS")
                }
            }
            return true
        } else {
            print("❌ Não é possível enviar SMS neste dispositivo")
            return false
        }
    }
    
    /// Copia texto para o clipboard
    /// - Parameter text: Texto a ser copiado
    public func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        print("📋 Texto copiado para clipboard: \(text)")
    }
    
    // MARK: - Verification Methods
    
    /// Verifica se o WhatsApp está instalado
    public func isWhatsAppInstalled() -> Bool {
        guard let url = URL(string: "whatsapp://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// Verifica se o Telegram está instalado
    public func isTelegramInstalled() -> Bool {
        guard let url = URL(string: "tg://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

// MARK: - Dependency Key

import ComposableArchitecture

extension DeepLinkService: TestDependencyKey {
    public static var testValue: DeepLinkService {
        return DeepLinkService.shared
    }
}

extension DependencyValues {
    public var deepLinkService: DeepLinkService {
        get { self[DeepLinkService.self] }
        set { self[DeepLinkService.self] = newValue }
    }
}



