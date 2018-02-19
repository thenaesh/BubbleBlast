//
//  ReflectingLine.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 20/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol ReflectingLine: StaticBody {
     var normal: Vector2D { get }
}

extension ReflectingLine {
    func collide(with otherBody: inout DynamicBody) {
        let v = otherBody.velocity
        let n = self.normal / self.normal.magnitude
        let dv = -2 * (v * n) * n
        otherBody.velocity += dv
    }

    func isColliding(with otherBody: DynamicBody) -> Bool {
        let displacementFromCentre = otherBody.position - self.position
        let projection = displacementFromCentre * self.normal / self.normal.magnitude
        return abs(projection) <= otherBody.boundingRadius
    }
}
