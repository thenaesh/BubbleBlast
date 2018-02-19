//
//  BubbleGrid.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

class BubbleGrid: Codable {
    var grid: [[FixedBubble?]]
    var projectile: ProjectileBubble? = nil

    init() {
        self.grid = Array.init(repeating: Array.init(repeating: nil, count: BUBBLES_PER_ROW), count: NUM_ROWS);
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                grid[row][col] = nil
            }
        }
    }

    func update() {
        trackProjectile()
    }

    func getBubbleAt(row: Int, col: Int) -> Bubble? {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return nil
        }

        return grid[row][col]
    }

    func setBubbleAt(row: Int, col: Int, to color: BubbleColor) {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return
        }

        if grid[row][col] == nil {
            grid[row][col] = FixedBubble(coords: BubbleGrid.getBubbleCentre(row: row, col: col), color: color)
        } else {
            grid[row][col]?.color = color
        }
    }

    func removeBubbleAt(row: Int, col: Int) {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return
        }

        grid[row][col] = nil
    }

    func setAllBubbles(to color: BubbleColor) {
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                setBubbleAt(row: row, col: col, to: color)
            }
        }
    }

    func removeAllBubbles() {
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                removeBubbleAt(row: row, col: col)
            }
        }
    }

    func loadProjectile() {
        let xCentre = maxX / 2 - 0.05
        let yCentre = maxY - BubbleGrid.radius
        self.projectile = ProjectileBubble(x: xCentre, y: yCentre, color: .redBubble)
    }

    func trackProjectile() {
        guard let projectile = self.projectile else  {
            return
        }
        guard projectile.status == .stopped else {
            return
        }

        let (row, col) = nearestGridPoint(from: projectile.position)
        setBubbleAt(row: row, col: col, to: projectile.color)
        self.projectile = nil
    }

    func nearestGridPoint(from position: Vector2D) -> (Int, Int) {
        var (nearestRow, nearestCol) = (-1, -1)
        var smallestDistance = Double.infinity

        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                let newPosition = BubbleGrid.getBubbleCentre(row: row, col: col)
                let dist = (position - newPosition).magnitude
                if dist < smallestDistance {
                    (nearestRow, nearestCol) = (row, col)
                    smallestDistance = dist
                }
            }
        }

        return (nearestRow, nearestCol)
    }

    var minX: Double {
        return 0
    }
    var maxX: Double {
        return 1
    }
    var minY: Double {
        return 0
    }
    var maxY: Double {
        return BubbleGrid.aspectRatio
    }

    static var aspectRatio: Double {
        return (2 + Double(NUM_ROWS - 1) * sqrt(3)) * radius
    }

    static var diameter: Double {
        return 1 / Double(BUBBLES_PER_ROW)
    }

    static var radius: Double {
        return diameter / 2
    }

    static func getBubbleCentre(row: Int, col: Int) -> Vector2D {
        let xCentre = (row % 2 == 0 ? 1 : 2) * radius + Double(col) * diameter
        let yCentre = radius + Double(row) * sqrt(3) * radius
        return Vector2D(xCentre, yCentre)
    }
}
