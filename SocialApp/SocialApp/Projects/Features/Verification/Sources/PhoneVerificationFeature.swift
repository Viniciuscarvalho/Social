import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct PhoneVerificationFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
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
                let verification = UserVerification(emailVerified: true, phoneVerified: true, verificationLevel: .phoneVerified)
                return .send(.delegate(.verificationCompleted(verification)))
            case .delegate:
                return .none
            }
        }
    }
}

public struct PhoneVerificationView: View {
    @Bindable var store: StoreOf<PhoneVerificationFeature>
    
    public init(store: StoreOf<PhoneVerificationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Verifique seu telefone")
                .foregroundStyle(.white)
            Button("Confirmar telefone") {
                store.send(.verify)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


