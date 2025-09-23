import Foundation

public struct Effect<Action> {
    private let operation: (@escaping (Action) async -> Void) async -> Void
    
    public init(operation: @escaping (@escaping (Action) async -> Void) async -> Void) {
        self.operation = operation
    }
    
    public static var none: Effect<Action> {
        Effect { _ in }
    }
    
    public static func send(_ action: Action) -> Effect<Action> {
        Effect { send in
            await send(action)
        }
    }
    
    public static func run(_ operation: @escaping (@escaping (Action) async -> Void) async -> Void) -> Effect<Action> {
        Effect(operation: operation)
    }
    
    public func map<NewAction>(_ transform: @escaping (Action) -> NewAction) -> Effect<NewAction> {
        Effect<NewAction> { send in
            await self.operation { action in
                await send(transform(action))
            }
        }
    }
}
