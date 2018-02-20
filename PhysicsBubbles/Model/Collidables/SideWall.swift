//
//  SideWall.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 20/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

class SideWall: ReflectingLine {
    enum Side {
        case left
        case right
    }

    var normal: Vector2D
    var position: Vector2D

    init(xPos: Double, side: Side) {
        self.position = Vector2D(xPos, 0)
        switch side {
        case .left:
            self.normal = Vector2D(1, 0)
        case .right:
            self.normal = Vector2D(-1, 0)
        }
    }
}
