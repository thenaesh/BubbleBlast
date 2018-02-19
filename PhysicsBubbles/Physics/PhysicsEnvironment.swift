//
//  PhysicsEnvironment.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol PhysicsEnvironment: AnyObject {
    var staticBodies: [StaticBody] { get }
    var dynamicBody: DynamicBody? { get set }
}

extension PhysicsEnvironment {
    func simulate(dt: Double) {
        guard var dynamicBody = dynamicBody else {
            return
        }

        dynamicBody.integrate(dt: dt)
        for staticBody in staticBodies where staticBody.isColliding(with: dynamicBody) {
            staticBody.collide(with: &dynamicBody)
            staticBody.doOnCollide(with: &dynamicBody)
        }
    }
}
