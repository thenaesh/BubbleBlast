//
//  Vector2D.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

struct Vector2D: Codable {
    var x: Double
    var y: Double

    init(_ x: Double = 0, _ y: Double = 0) {
        self.x = x
        self.y = y
    }

    var magnitude: Double {
        return sqrt(x * x + y * y)
    }
}

extension Vector2D {
    static func + (_ lhs: Vector2D, _ rhs: Vector2D) -> Vector2D {
        return Vector2D(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func - (_ lhs: Vector2D, _ rhs: Vector2D) -> Vector2D {
        return lhs + (rhs * -1)
    }

    static func += (_ lhs: inout Vector2D, _ rhs: Vector2D) {
        lhs = lhs + rhs
    }

    static func -= (_ lhs: inout Vector2D, _ rhs: Vector2D) {
        lhs = lhs - rhs
    }

    static func * (_ lhs: Vector2D, _ rhs: Double) -> Vector2D {
        return Vector2D(lhs.x * rhs, lhs.y * rhs)
    }

    static func * (_ lhs: Vector2D, _ rhs: Vector2D) -> Vector2D {
        return Vector2D(lhs.x * rhs.x, lhs.y * rhs.y)
    }

    static func *= (_ lhs: inout Vector2D, _ rhs: Vector2D) {
        lhs = lhs * rhs
    }

    static func *= (_ lhs: inout Vector2D, _ rhs: Double) {
        lhs = lhs * rhs
    }
}
