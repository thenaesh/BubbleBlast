//
//  FixedBubble.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 18/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation
import PhysicsEngine

class SnappingBubble: Bubble, StickyCircle {
    // only magnetic bubbles have mass, so they can attract other bubbles
    var mass: Double? {
        return self.color == .magneticBubble ? 1 : nil
    }

    override init(x: Double, y: Double, color: BubbleColor) {
        super.init(x: x, y: y, color: color)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    func doOnCollide(with otherBody: inout DynamicBody) {
        guard let otherBody = otherBody as? ProjectileBubble else {
            return
        }

        otherBody.status = .stopped
    }
}
