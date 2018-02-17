//
//  Bubble.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation


enum Bubble: String, Codable {
    case redBubble
    case greenBubble
    case blueBubble
    case orangeBubble
}

extension Bubble {
    func next() -> Bubble {
        switch self {
        case .redBubble:
            return .greenBubble
        case .greenBubble:
            return .blueBubble
        case .blueBubble:
            return .orangeBubble
        case .orangeBubble:
            return .redBubble
        }
    }
}
