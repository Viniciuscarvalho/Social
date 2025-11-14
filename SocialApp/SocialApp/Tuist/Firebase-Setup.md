# Firebase Setup para SocialApp

## 1. Adicionar Firebase via Swift Package Manager

1. Abra o projeto no Xcode
2. Vá em **File → Add Package Dependencies**
3. Cole a URL: `https://github.com/firebase/firebase-ios-sdk.git`
4. Selecione a versão mais recente (10.x.x ou superior)
5. Adicione os seguintes produtos:
   - **FirebaseMessaging** (para Push Notifications)
   - **FirebaseAnalytics** (opcional, para analytics)

## 2. Configurar Firebase no Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto ou selecione existente
3. Adicione um app iOS:
   - Bundle ID: `com.socialclub.app` (ou seu bundle ID)
   - Baixe o arquivo `GoogleService-Info.plist`

## 3. Adicionar GoogleService-Info.plist ao Projeto

1. Arraste o arquivo `GoogleService-Info.plist` para a pasta **SocialApp/Resources/**
2. Certifique-se de marcar **"Copy items if needed"**
3. Adicione ao target principal

## 4. Configurar APNs (Apple Push Notification service)

### 4.1. Criar APNs Key no Apple Developer

1. Acesse [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
2. Clique em **"+"** para criar uma nova key
3. Marque **Apple Push Notifications service (APNs)**
4. Baixe o arquivo `.p8`
5. Anote o **Key ID** e **Team ID**

### 4.2. Configurar no Firebase Console

1. No Firebase Console, vá em **Project Settings → Cloud Messaging**
2. Na seção **APNs Authentication Key**, clique em **Upload**
3. Faça upload do arquivo `.p8`
4. Insira o **Key ID** e **Team ID**

## 5. Adicionar Capabilities no Xcode

1. Selecione o target **SocialApp**
2. Vá em **Signing & Capabilities**
3. Clique em **+ Capability**
4. Adicione:
   - **Push Notifications**
   - **Background Modes** → marque **Remote notifications**

## 6. Configurar AppDelegate

Crie ou atualize o `AppDelegate.swift`:

```swift
import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configurar Firebase
        FirebaseApp.configure()
        
        // Configurar Messaging delegate
        Messaging.messaging().delegate = self
        
        // Solicitar autorização de notificações
        UNUserNotificationCenter.current().delegate = PushNotificationService.shared
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Passar token para Firebase
        Messaging.messaging().apnsToken = deviceToken
        
        // Passar para nosso serviço
        PushNotificationService.shared.setDeviceToken(deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }
        print("🔥 FCM Token: \(token)")
        
        // Enviar para backend
        PushNotificationService.shared.setFCMToken(token)
    }
}
```

## 7. Atualizar SocialApp.swift

```swift
import SwiftUI
import FirebaseCore

@main
struct SocialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let store = Store(initialState: SocialAppFeature.State()) {
        SocialAppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            SocialAppView(store: store)
                .backgroundProtection()
                .onAppear {
                    // Solicitar permissão de notificações
                    Task {
                        try? await PushNotificationService.shared.requestAuthorization()
                    }
                }
        }
    }
}
```

## 8. Testar Push Notifications

### Via Firebase Console (Manual)

1. No Firebase Console, vá em **Engage → Messaging**
2. Clique em **Send your first message**
3. Escreva título e mensagem
4. Selecione o app iOS
5. Clique em **Send**

### Via API (Programático)

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Nova Negociação",
      "body": "João quer negociar seu ingresso"
    },
    "data": {
      "type": "negotiation_request",
      "id": "nego-123",
      "ticketId": "ticket-456"
    }
  }'
```

## 9. Payload Structure para Deep Links

```json
{
  "notification": {
    "title": "Notificação",
    "body": "Mensagem"
  },
  "data": {
    "type": "negotiation_approved",
    "id": "negotiation-id",
    "ticketId": "ticket-id",
    "userId": "user-id"
  }
}
```

### Tipos de Notificação Suportados:

- `negotiation_request` - Nova solicitação de negociação
- `negotiation_approved` - Negociação aprovada
- `negotiation_rejected` - Negociação recusada
- `contact_revealed` - Contato revelado
- `validation_approved` - Validação aprovada
- `validation_rejected` - Validação rejeitada
- `review_received` - Nova avaliação recebida

## 10. Verificar Integração

Execute o app e verifique os logs:

```
✅ Firebase configured
📱 Push notifications authorized
📱 Device Token: abc123...
🔥 FCM Token: xyz789...
✅ Token enviado para backend
```

## Troubleshooting

### Notificações não chegam:

1. Verifique se o certificado APNs está correto no Firebase
2. Verifique se o app tem permissão de notificações
3. Teste no dispositivo físico (simulador não recebe push)
4. Verifique logs no Firebase Console

### FCM Token não é gerado:

1. Certifique-se que `GoogleService-Info.plist` está no bundle
2. Verifique se FirebaseApp.configure() é chamado
3. Reinicie o app e verifique os logs

### Deep links não funcionam:

1. Verifique se `NotificationCenter` observers estão configurados
2. Verifique se o payload tem o campo `data.type`
3. Adicione logs em `handleDeepLink` para debug












