//
//  BubbleGrid.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

class BubbleGrid: Codable {
    var grid: [[Bubble?]]

    init() {
        self.grid = Array.init(repeating: Array.init(repeating: nil, count: BUBBLES_PER_ROW), count: NUM_ROWS);
        setAllBubbles(to: .eraseBubble)
    }

    func getBubbleAt(row: Int, col: Int) -> Bubble? {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return nil
        }

        return grid[row][col]
    }

    func setBubbleAt(row: Int, col: Int, to bubble: Bubble) {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return
        }
        grid[row][col] = bubble
    }

    func setAllBubbles(to bubble: Bubble) {
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                setBubbleAt(row: row, col: col, to: bubble)
            }
        }
    }
}
