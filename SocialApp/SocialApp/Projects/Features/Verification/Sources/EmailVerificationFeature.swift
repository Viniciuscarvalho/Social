import ComposableArchitecture
import Foundation

@Reducer
public struct EmailVerificationFeature {
    @ObservableState
    public struct State: Equatable {
        public var email: String
        public init(email: String = "") {
            self.email = email
        }
    }
    
    public enum Action {
        case verify
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case verificationCompleted(UserVerification)
            case dismiss
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .verify:
                // Simula sucesso imediato apenas para compilar/rodar
                let verification = UserVerification(emailVerified: true, phoneVerified: false, verificationLevel: .emailVerified)
                return .send(.delegate(.verificationCompleted(verification)))
            case .delegate:
                return .none
            }
        }
    }
}

import SwiftUI

public struct EmailVerificationView: View {
    @Bindable var store: StoreOf<EmailVerificationFeature>
    
    public init(store: StoreOf<EmailVerificationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Verifique seu e-mail")
                .foregroundStyle(.white)
            Button("Confirmar e-mail") {
                store.send(.verify)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


