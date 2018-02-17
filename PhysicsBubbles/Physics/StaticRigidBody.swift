//
//  FreeBody.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 17/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

protocol StaticRigidBody {
    var position: Vector2D { get }
    
    func collide(with otherBody: DynamicRigidBody)
}
