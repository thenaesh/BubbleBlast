//
//  ReflectingSideWall.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 19/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

class ReflectingSideWall: StaticBody {
    enum Side {
        case left
        case right
    }

    var position: Vector2D
    var normal: Vector2D

    init(side: Side) {
        switch side {
        case .left:
            self.position = Vector2D(0, 0)
            self.normal = Vector2D(1, 0)
        case .right:
            self.position = Vector2D(1, 0)
            self.normal = Vector2D(-1, 0)
        }
    }

    func isColliding(with otherBody: DynamicBody) -> Bool {
        return abs(otherBody.position.x - self.position.x) <= BubbleGrid.radius
    }

    func collide(with otherBody: inout DynamicBody) {
        let v = otherBody.velocity
        let n = self.normal
        otherBody.velocity = v - n * (v * n * 2)
    }
}
