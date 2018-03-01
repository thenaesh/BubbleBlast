//
//  BubbleGrid.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import PhysicsEngine

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

    func createProjectile() {
        let xCentre = maxX / 2 - 0.05
        let yCentre = maxY - 2 * Bubble.radius
        self.projectile = ProjectileBubble(x: xCentre, y: yCentre, color: BubbleColor.random())
    }

    func destroyProjectile() {
        self.projectile = nil
    }

    func nearestUnoccupiedGridPoint(from position: Vector2D) -> (Int, Int) {
        var (nearestRow, nearestCol) = (-1, -1)
        var smallestDistance = Double.infinity

        func canSelectGridPoint(_ row: Int, _ col: Int) -> Bool {
            return isBubbleIndexAllowable(row: row, col: col) && getBubbleAt(row: row, col: col) == nil
        }

        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where canSelectGridPoint(row, col) {
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

    func getAllBubblesSatisfying(condition: (Bubble) -> Bool) -> [(Int, Int)] {
        var satisfyingBubbles = [(Int, Int)]()

        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                satisfyingBubbles.append((row, col))
            }
        }

        return satisfyingBubbles.filter({ (r, c) in
            guard let bubble = self.getBubbleAt(row: r, col: c) else {
                return false
            }
            return condition(bubble)
        })
    }

    func getAdjacentTo(row: Int, col: Int, with color: BubbleColor? = nil) -> [(Int, Int)] {
        var adj = [(row, col - 1), (row, col + 1), (row - 1, col), (row + 1, col)]

        if row % 2 == 1 {
            adj.append((row - 1, col + 1))
            adj.append((row + 1, col + 1))
        } else {
            adj.append((row - 1, col - 1))
            adj.append((row + 1, col - 1))
        }

        adj = adj.filter({ (r, c) in isBubbleIndexAllowable(row: r, col: c) && getBubbleAt(row: r, col: c) != nil })

        guard let color = color else {
            return adj
        }
        return adj.filter({ (r, c) in getBubbleAt(row: r, col: c)?.color == color })
    }

    func getBubbleClusterAt(row: Int, col: Int, of color: BubbleColor? = nil) -> [(Int, Int)] {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return []
        }

        // standard DFS algorithm to find connected component
        var cluster = [(Int, Int)]()
        var frontier = [(Int, Int)]()
        var elemsInFrontier = Set<HashableIntPair>()

        frontier.append((row, col))
        elemsInFrontier.insert(HashableIntPair(row, col))

        while let next = frontier.popLast() {
            let (nextRow, nextCol) = next
            cluster.append(next)

            for (r, c) in getAdjacentTo(row: nextRow, col: nextCol, with: color) where !elemsInFrontier.contains(HashableIntPair(r, c)){
                frontier.append((r, c))
                elemsInFrontier.insert(HashableIntPair(r, c))
            }
        }

        return cluster
    }

    func getFloatingBubbles() -> [(Int, Int)] {
        var allBubbles = [(Int, Int)]()

        // initially, all bubbles in the grid are under consideration
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where getBubbleAt(row: row, col: col) != nil {
                allBubbles.append((row, col))
            }
        }

        var nonFloatingBubbles = Set<HashableIntPair>()
        let ceilingBubbles = (0..<BUBBLES_PER_ROW).map({ (c) in (0, c) })
                                                  .filter({ (r,c) in self.getBubbleAt(row: r, col: c) != nil })

        // if a bubble is attached to ceiling, DFS from there to find the connected component starting from the ceiling
        for (ceilingRow, ceilingCol) in ceilingBubbles {
            // add connected component to nonFloatingBubbles
            getBubbleClusterAt(row: ceilingRow, col: ceilingCol).forEach({ (rowcol) in nonFloatingBubbles.insert(HashableIntPair(rowcol)) })
        }

        let floatingBubbles = allBubbles.filter({ (rowcol) in !nonFloatingBubbles.contains(HashableIntPair(rowcol)) })
        return floatingBubbles
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
        return (2 + Double(NUM_ROWS - 1) * sqrt(3)) * Bubble.radius
    }


    static func getBubbleCentre(row: Int, col: Int) -> Vector2D {
        let xCentre = (row % 2 == 0 ? 1 : 2) * Bubble.radius + Double(col) * Bubble.diameter
        let yCentre = Bubble.radius + Double(row) * sqrt(3) * Bubble.radius
        return Vector2D(xCentre, yCentre)
    }
}
