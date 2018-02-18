//
//  Bubble.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation


enum BubbleColor: String, Codable {
    case redBubble
    case greenBubble
    case blueBubble
    case orangeBubble
}

class Bubble: Codable {
    var position: Vector2D
    var color: BubbleColor

    init(x: Double, y: Double, color: BubbleColor) {
        self.position = Vector2D(x, y)
        self.color = color
    }

    convenience init (coords: Vector2D, color: BubbleColor) {
        self.init(x: coords.x, y: coords.y, color: color)
    }
}

extension BubbleColor {
    func next() -> BubbleColor {
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
