import ComposableArchitecture
import Foundation

@Reducer
public struct SearchFeature {
    @ObservableState
    public struct State: Equatable {
        public var searchText: String = ""
        public var searchResults: [Event] = []
        public var recentSearches: [String] = []
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {
            // Load recent searches from UserDefaults
            if let saved = UserDefaults.standard.stringArray(forKey: "recentSearches") {
                self.recentSearches = saved
            }
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case searchTextChanged(String)
        case searchResponse(Result<[Event], NetworkError>)
        case eventSelected(UUID)
        case clearSearch
        case cancelSearch
        case performSearch(String)
        case removeRecentSearch(String)
        case selectRecentSearch(String)
    }
    
    @Dependency(\.eventsClient) var eventsClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                
                if text.isEmpty {
                    state.searchResults = []
                    state.isLoading = false
                    return .cancel(id: SearchID.search)
                }
                
                // Otimização: só busca com 2+ caracteres
                if text.count < 2 {
                    state.searchResults = []
                    state.isLoading = false
                    return .cancel(id: SearchID.search)
                }
                
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [searchText = text] send in
                    // Debounce melhorado para otimizar busca
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    do {
                        // Filtra eventos por nome, descrição e localização
                        let events = try await eventsClient.searchEvents(searchText)
                        await send(.searchResponse(.success(events)))
                    } catch {
                        await send(.searchResponse(.failure(NetworkError.unknown(error.localizedDescription))))
                    }
                }
                .cancellable(id: SearchID.search)
                
            case let .searchResponse(.success(events)):
                state.searchResults = events
                state.isLoading = false
                state.errorMessage = nil
                return .none
                
            case let .searchResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                state.searchResults = []
                return .none
                
            case .clearSearch:
                state.searchText = ""
                state.searchResults = []
                state.isLoading = false
                return .cancel(id: SearchID.search)
                
            case .eventSelected:
                return .none
                
            case .cancelSearch:
                return .none
                
            case let .performSearch(query):
                guard !query.isEmpty else { return .none }
                
                // Add to recent searches
                var updatedSearches = state.recentSearches.filter { $0 != query }
                updatedSearches.insert(query, at: 0)
                updatedSearches = Array(updatedSearches.prefix(10)) // Keep only last 10
                state.recentSearches = updatedSearches
                
                // Save to UserDefaults
                UserDefaults.standard.set(updatedSearches, forKey: "recentSearches")
                
                // Trigger search
                state.searchText = query
                return .run { send in
                    await send(.searchTextChanged(query))
                }
                
            case let .removeRecentSearch(query):
                state.recentSearches.removeAll { $0 == query }
                UserDefaults.standard.set(state.recentSearches, forKey: "recentSearches")
                return .none
                
            case let .selectRecentSearch(query):
                return .run { send in
                    await send(.performSearch(query))
                }
            }
        }
    }
}

private enum SearchID {
    case search
}
