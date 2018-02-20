//
//  StaticBody.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol StaticBody {
    var position: Vector2D { get }

    func isColliding(with otherBody: DynamicBody) -> Bool
    func collide(with otherBody: inout DynamicBody)
    func doOnCollide(with otherBody: inout DynamicBody)
}

extension StaticBody {
    func doOnCollide(with otherBody: inout DynamicBody) {
        // do nothing as a default implementation
    }
}
