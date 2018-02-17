//
//  PhysicsEnvironment.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol PhysicsEnvironment {
    func simulate(dt: Double)
}

extension PhysicsEnvironment {
    func simulate(dt: Double) {
        print(dt)
    }
}
