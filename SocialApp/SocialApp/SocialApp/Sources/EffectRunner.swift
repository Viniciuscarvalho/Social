import Foundation
import ComposableArchitecture
import SharedModels

extension SharedModels.Effect where Action: Equatable {
    func run(send: @escaping (Action) -> Void) {
        Task {
            await operation { action in
                send(action)
            }
        }
    }
}

// Para integrar com TCA Effects no SocialAppFeature
extension ComposableArchitecture.Effect {
    static func fromCustomEffect<A: Equatable>(_ customEffect: SharedModels.Effect<A>) -> ComposableArchitecture.Effect<A> {
        return .run { send in
            await customEffect.operation { action in
                await send(action)
            }
        }
    }
}
