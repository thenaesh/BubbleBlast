//
//  StickyCeiling.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 19/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

class StickyCeiling: StaticBody {
    var position = Vector2D(0, 0)

    func isColliding(with otherBody: DynamicBody) -> Bool {
        return otherBody.position.y - self.position.y <= BubbleGrid.radius
    }

    func collide(with otherBody: inout DynamicBody) {
        // if a projectile bubble collided with me, stop the bubble
        if let otherBody = otherBody as? ProjectileBubble {
            otherBody.velocity *= 0
            otherBody.status = .stopped
        }
    }


}
