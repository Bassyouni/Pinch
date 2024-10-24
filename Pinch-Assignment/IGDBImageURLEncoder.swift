//
//  IGDBImageURLEncoder.swift
//  Pinch-Assignment
//
//  Created by Omar Bassyouni on 24/10/2024.
//

import Foundation

public struct IGDBGameImageURLEncoder: GameImageURLEncoder {
    public init() {}
    
    public func encode(_ url: URL, forSize size: GameImageSize) -> URL {
        var urlString = url.absoluteString
        
        if !urlString.hasPrefix("https:") {
            urlString = "https:" + urlString
        }
        
        if let range = urlString.range(of: "t_[^/]+", options: .regularExpression) {
            switch size {
            case .portrait:
                urlString.replaceSubrange(range, with: "t_cover_med")
                
            case .landscape:
                urlString.replaceSubrange(range, with: "t_screenshot_med")
            }
        }
        
        return URL(string: urlString) ?? url
    }
}
