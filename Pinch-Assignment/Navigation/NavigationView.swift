//
//  NavigationView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import SwiftUI

struct AppNavigationView<Content: View>: View {
    
    typealias MakeView = (NavigationRoute, NavigationRouter) -> Content
    
    let view: MakeView
    @StateObject var router = NavigationRouter()
    
    init(@ViewBuilder view: @escaping MakeView) {
        self.view = view
    }
    
    var body: some View {
        NavigationStack(path: $router.stack) {
            view(router.root, router)
                .navigationDestination(
                    for: NavigationRoute.self,
                    destination: { destination in
                        view(destination, router)
                            .id(destination)
                    }
                )
        }
    }
}
