//
//  BubbleGrid+PhysicsEnvironment.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 18/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation
import PhysicsEngine

extension BubbleGrid: PhysicsEnvironment {

    var staticBodies: [StaticBody] {
        var staticBodyArray = [StaticBody]()
        
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                if let bubble = self.grid[row][col] {
                    staticBodyArray.append(bubble)
                }
            }
        }

        let stickyCeiling = Ceiling()
        staticBodyArray.append(stickyCeiling)

        let leftReflectingSideWall = SideWall(xPos: 0, side: .left)
        let rightReflectingSideWall = SideWall(xPos: 1, side: .right)
        staticBodyArray.append(leftReflectingSideWall)
        staticBodyArray.append(rightReflectingSideWall)

        return staticBodyArray
    }

    var dynamicBody: DynamicBody? {
        get {
         return self.projectile
        }
        set {
            guard let newValue = newValue else {
                return
            }

            self.projectile?.position = newValue.position
            self.projectile?.velocity = newValue.velocity
            self.projectile?.acceleration = newValue.acceleration
        }
    }

}
