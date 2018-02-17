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

struct Bubble: Codable {
    var x: Double
    var y: Double
    var color: BubbleColor

    init(x: Double, y: Double, color: BubbleColor) {
        self.x = x
        self.y = y
        self.color = color
    }

    init (coords: (Double, Double), color: BubbleColor) {
        self.init(x: coords.0, y: coords.1, color: color)
    }

    var coords: (Double, Double) {
        return (x, y)
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
