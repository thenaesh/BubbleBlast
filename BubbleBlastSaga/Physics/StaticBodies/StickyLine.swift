//
//  StickyLine.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 20/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol StickyLine: StaticBody {
    var normal: Vector2D { get }
}

extension StickyLine {
    func collide(with otherBody: inout DynamicBody) {
        otherBody.velocity *= 0
    }
    
    func isColliding(with otherBody: DynamicBody) -> Bool {
        let displacementFromCentre = otherBody.position - self.position
        let projection = displacementFromCentre * self.normal / self.normal.magnitude
        return abs(projection) <= otherBody.boundingRadius
    }
}
