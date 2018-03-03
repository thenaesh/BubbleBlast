//
//  Vector2D.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

public struct Vector2D: Codable {
    public var x: Double
    public var y: Double

    public init(_ x: Double = 0, _ y: Double = 0) {
        self.x = x
        self.y = y
    }

    public var magnitude: Double {
        return sqrt(x * x + y * y)
    }

    public var normalized: Vector2D {
        return self / self.magnitude
    }

    public static let zero = Vector2D(0, 0)
}

public extension Vector2D {
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

    static func * (_ lhs: Vector2D, _ rhs: Vector2D) -> Double {
        return lhs.x * rhs.x + lhs.y * rhs.y
    }

    static func * (_ lhs: Vector2D, _ rhs: Double) -> Vector2D {
        return Vector2D(lhs.x * rhs, lhs.y * rhs)
    }

    static func / (_ lhs: Vector2D, _ rhs: Double) -> Vector2D {
        return lhs * (1 / rhs)
    }

    static func * (_ lhs: Double, _ rhs: Vector2D) -> Vector2D {
        return rhs * lhs
    }


    static func *= (_ lhs: inout Vector2D, _ rhs: Double) {
        lhs = lhs * rhs
    }

    static func /= (_ lhs: inout Vector2D, _ rhs: Double) {
        lhs = lhs / rhs
    }
}
