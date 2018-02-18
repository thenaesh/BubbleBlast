//
//  ProjectileBubble.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 18/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

class ProjectileBubble: Bubble, DynamicBody {
    var velocity: Vector2D
    var acceleration: Vector2D

    override init(x: Double, y: Double, color: BubbleColor) {
        self.velocity = Vector2D(0, 0)
        self.acceleration = Vector2D(0, 0)
        super.init(x: x, y: y, color: color)
    }

    required init(from decoder: Decoder) throws {
        self.velocity = Vector2D(0, 0)
        self.acceleration = Vector2D(0, 0)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
