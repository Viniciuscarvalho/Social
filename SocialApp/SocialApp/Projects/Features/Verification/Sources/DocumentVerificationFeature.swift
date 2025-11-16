import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct DocumentVerificationFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case submit
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case verificationSubmitted(UserVerification)
            case dismiss
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .submit:
                let verification = UserVerification(emailVerified: true, phoneVerified: true, verificationLevel: .verified)
                return .send(.delegate(.verificationSubmitted(verification)))
            case .delegate:
                return .none
            }
        }
    }
}

public struct DocumentVerificationView: View {
    @Bindable var store: StoreOf<DocumentVerificationFeature>
    
    public init(store: StoreOf<DocumentVerificationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Envie seu documento")
                .foregroundStyle(.white)
            Button("Enviar documento") {
                store.send(.submit)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


