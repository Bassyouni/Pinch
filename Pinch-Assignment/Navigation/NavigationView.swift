//
//  NavigationView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import SwiftUI

struct AppNavigationView<Content: View>: View {
    
    let view: (NavigationRoute) -> Content
    @StateObject var router: NavigationRouter
    
    init(router: NavigationRouter, @ViewBuilder view: @escaping (NavigationRoute) -> Content) {
        self.view = view
        self._router = .init(wrappedValue: router)
    }
    
    var body: some View {
        NavigationStack(path: $router.stack) {
            view(router.root)
                .navigationDestination(
                    for: NavigationRoute.self,
                    destination: { destination in
                        view(destination)
                            .id(destination)
                    }
                )
        }
    }
}
