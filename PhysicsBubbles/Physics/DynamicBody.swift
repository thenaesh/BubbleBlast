//
//  DynamicBody.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol DynamicBody {
    var position: Vector2D { get set }
    var velocity: Vector2D { get set }
    var acceleration: Vector2D { get set }

    mutating func integrate(dt: Double)
}

extension DynamicBody {
    mutating func integrate(dt: Double) {
        velocity += acceleration * dt
        position += velocity * dt
    }
}
