//
//  ProjectileBubble.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 18/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation
import PhysicsEngine

class ProjectileBubble: Bubble, DynamicBody {
    enum Status {
        case ready
        case flying
        case stopped
        case stoppedWithoutSnapping
    }

    var boundingRadius = Bubble.radius
    var velocity: Vector2D
    var acceleration: Vector2D
    var isAnchored: Bool = true
    var status = Status.ready
    let isNonSnapping: Bool

    override init(x: Double, y: Double, color: BubbleColor) {
        //self.isNonSnapping = randomChoiceFrom([true, false])
        self.isNonSnapping = false
        self.velocity = Vector2D(0, 0)
        self.acceleration = Vector2D(0, 0)
        super.init(x: x, y: y, color: color)
    }

    required init(from decoder: Decoder) throws {
        self.isNonSnapping = randomChoiceFrom([true, false])
        self.velocity = Vector2D(0, 0)
        self.acceleration = Vector2D(0, 0)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
