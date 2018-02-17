//
//  Vector2D.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

struct Vector2D {
    var x: Double
    var y: Double

    init(_ x: Double = 0, _ y: Double = 0) {
        self.x = x
        self.y = y
    }
}

extension Vector2D {
    static func + (_ lhs: Vector2D, _ rhs: Vector2D) -> Vector2D {
        return Vector2D(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func += (_ lhs: inout Vector2D, _ rhs: Vector2D) {
        lhs = lhs + rhs
    }
}
