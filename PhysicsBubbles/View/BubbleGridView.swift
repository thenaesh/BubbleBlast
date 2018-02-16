//
//  BubbleGridView.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 10/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class BubbleGridView {
    let uiView = UIView()
    private let parentView: UIView
    private var grid: [[BubbleView]] = []

    init(parentView: UIView) {
        self.parentView = parentView
        attachGridViewToParent()
        fixAspectRatio()
        createBubbleGrid()
    }

    private func attachGridViewToParent() {
        uiView.frame.size = parentView.frame.size
        parentView.addSubview(uiView)
    }

    private func fixAspectRatio() {
        let newHeight = (2 + Double(NUM_ROWS - 1) * sqrt(3)) * radius
        uiView.frame.size.height = CGFloat(newHeight)
    }

    private func createBubbleGrid() {
        for row in 0..<NUM_ROWS {
            grid.append([])
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                let bubbleToAdd = BubbleView(frame: getBubbleFrame(row: row, col: col))
                grid[row].append(bubbleToAdd)
                addBubbleToGrid(bubbleToAdd)
            }
        }
    }

    func getBubbleIndexAt(coords: CGPoint) -> (Int, Int)? {
        // nil could be used instead, but that would introduce more checks later
        // this is automatically handled by the call to getBubbleAt(row: Int, col: Int) anyway
        let invalidIndex = -1

        var row: Int = invalidIndex
        var col: Int = invalidIndex

        for r in 0..<NUM_ROWS {
            for c in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: r, col: c) && grid[r][c].uiView.frame.contains(coords) {
                row = r
                col = c
            }
        }

        guard isBubbleIndexAllowable(row: row, col: col) else {
            return nil
        }

        return (row, col)
    }

    func getBubbleViewAt(coords: CGPoint) -> BubbleView? {
        guard let (row, col): (Int, Int) = getBubbleIndexAt(coords: coords) else {
            return nil
        }

        return getBubbleViewAt(row: row, col: col)
    }

    func getBubbleViewAt(row: Int, col: Int) -> BubbleView? {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return nil
        }
        return grid[row][col]
    }

    private func getBubbleFrame(row: Int, col: Int) -> CGRect {
        let xCentre = (row % 2 == 0 ? 1 : 2) * radius + Double(col) * diameter
        let yCentre = radius + Double(row) * sqrt(3) * radius
        let xTopLeftCorner = xCentre - radius
        let yTopLeftCorner = yCentre - radius
        return CGRect(x: xTopLeftCorner, y: yTopLeftCorner, width: diameter, height: diameter)
    }

    private func addBubbleToGrid(_ bubbleView: BubbleView) {
        uiView.addSubview(bubbleView.uiView)
    }

    func render(row: Int, col: Int, as bubble: Bubble?) {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return
        }
        let bubbleView = getBubbleViewAt(row: row, col: col)
        bubbleView?.render(as: bubble)
    }

    private var radius: Double {
        return Double(uiView.frame.size.width) / Double(BUBBLES_PER_ROW * 2)
    }
    private var diameter: Double {
        return 2 * radius
    }
}
