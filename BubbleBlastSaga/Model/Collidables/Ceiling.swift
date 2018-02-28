//
//  Ceiling.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 19/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation
import PhysicsEngine

class Ceiling: StickyLine {
    var normal = Vector2D(0, 1)
    var position = Vector2D(0, 0)

    func doOnCollide(with otherBody: inout DynamicBody) {
        guard let otherBody = otherBody as? ProjectileBubble else {
            return
        }

        otherBody.status = .stopped
    }


}
