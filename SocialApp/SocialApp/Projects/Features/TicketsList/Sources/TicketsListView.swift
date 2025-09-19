import ComposableArchitecture
import SwiftUI

public struct TicketsListView: View {
    @Bindable var store: StoreOf<TicketsListFeature>
    
    public init(store: StoreOf<TicketsListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "ticket.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                Text("Lista de Ingressos")
                    .font(.title)
                Text("Em desenvolvimento")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Ingressos")
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}