//
//  StaticBody.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

public protocol StaticBody {
    var position: Vector2D { get }
    var mass: Double? { get }

    func isColliding(with otherBody: DynamicBody) -> Bool
    func collide(with otherBody: inout DynamicBody)
    func attract(_ otherBody: inout DynamicBody)
    func doOnCollide(with otherBody: inout DynamicBody)
}

public extension StaticBody {
    func attract(_ otherBody: inout DynamicBody) {
        guard let mass = self.mass, mass > 0 else {
            return
        }

        let distanceBetweenBodies = (self.position - otherBody.position).magnitude
        let accelerationDirection = (self.position - otherBody.position).normalized
        let accelerationMagnitude = mass / (distanceBetweenBodies * distanceBetweenBodies)
        
        otherBody.acceleration += accelerationDirection * accelerationMagnitude
    }

    func doOnCollide(with otherBody: inout DynamicBody) {
        // do nothing as a default implementation
    }
}
