import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct TicketsListFeature {
    @ObservableState
    public struct State: Equatable {
        public var tickets: [Ticket] = []
        public var isLoading: Bool = false
        
        public init() {}
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadTickets
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadTickets)
                
            case .loadTickets:
                state.isLoading = true
                // Simulate loading
                return .none
            }
        }
    }
}