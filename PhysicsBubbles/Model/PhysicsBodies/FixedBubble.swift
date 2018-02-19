//
//  FixedBubble.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 18/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

class FixedBubble: Bubble, StaticBody {
    override init(x: Double, y: Double, color: BubbleColor) {
        super.init(x: x, y: y, color: color)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    func isColliding(with otherBody: DynamicBody) -> Bool {
        return (self.position - otherBody.position).magnitude <= BubbleGrid.diameter
    }

    func collide(with otherBody: inout DynamicBody) {
        // if a projectile bubble collided with me, stop the bubble
        if let otherBody = otherBody as? ProjectileBubble {
            otherBody.velocity *= 0
            otherBody.status = .stopped
        }
    }
}
