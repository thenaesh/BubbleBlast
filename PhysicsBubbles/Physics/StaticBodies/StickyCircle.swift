//
//  StickyCircle.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 20/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol StickyCircle: StaticBody {
}

extension StickyCircle {
    func collide(with otherBody: inout DynamicBody) {
        otherBody.velocity *= 0
    }
    
    func isColliding(with otherBody: DynamicBody) -> Bool {
        return (self.position - otherBody.position).magnitude <= otherBody.boundingRadius
    }
}
