//
//  ViewState.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 22/10/2024.
//

import Foundation

public enum ViewState<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case error(message: String)
}
