//
//  Bubble.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import PhysicsEngine


enum BubbleColor: String, Codable {
    case redBubble
    case greenBubble
    case blueBubble
    case orangeBubble
    case indestructibleBubble
    case lightningBubble
    case bombBubble
    case starBubble
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

    static var diameter: Double {
        return 1 / Double(BUBBLES_PER_ROW)
    }

    static var radius: Double {
        return diameter / 2
    }

    func isSpecial() -> Bool {
        let specialBubbles: [BubbleColor] = [.indestructibleBubble, .lightningBubble, .bombBubble, .starBubble]
        return specialBubbles.contains(self.color)
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
            return .indestructibleBubble
        case .indestructibleBubble:
            return .lightningBubble
        case .lightningBubble:
            return .bombBubble
        case .bombBubble:
            return .starBubble
        case .starBubble:
            return .redBubble
        }
    }

    static func random() -> BubbleColor {
        let choices: [BubbleColor] = [.redBubble, .greenBubble, .blueBubble, .orangeBubble]
        let randomIndex = Int(arc4random_uniform(UInt32(choices.count)))
        return choices[randomIndex]
    }
}
