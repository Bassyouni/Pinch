//
//  NavigationView.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 23/10/2024.
//

import SwiftUI

struct AppNavigationView<Content: View>: View {
    
    @StateObject var router = NavigationRouter()
    let view: (NavigationRoute) -> Content
    
    init(@ViewBuilder view: @escaping (NavigationRoute) -> Content) {
        self.view = view
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
