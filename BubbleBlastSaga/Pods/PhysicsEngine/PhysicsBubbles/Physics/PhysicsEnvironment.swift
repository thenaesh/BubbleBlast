//
//  PhysicsEnvironment.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

public protocol PhysicsEnvironment: AnyObject {
    var staticBodies: [StaticBody] { get }
    var dynamicBody: DynamicBody? { get set }
}

public extension PhysicsEnvironment {
    func simulate(dt: Double) {
        guard var dynamicBody = dynamicBody, !dynamicBody.isAnchored else {
            return
        }

        dynamicBody.integrate(dt: dt)

        for staticBody in staticBodies {
            staticBody.attract(&dynamicBody)
        }
        
        for staticBody in staticBodies where staticBody.isColliding(with: dynamicBody) {
            staticBody.collide(with: &dynamicBody)
            staticBody.doOnCollide(with: &dynamicBody)
        }
    }
}
