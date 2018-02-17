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
    private let model: BubbleGrid
    private var grid: [[BubbleView]] = []
    private var projectileView: BubbleView? = nil

    init(parentView: UIView, model: BubbleGrid) {
        self.parentView = parentView
        self.model = model
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

    func loadProjectileView() {
        guard let projectileModel = model.projectile else {
            return
        }

        projectileView = BubbleView(frame: getProjectileFrameFor(projectileModel.coords))
        uiView.addSubview(projectileView!.uiView)
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

    func getProjectileFrameFor(_ coords: (Double, Double)) -> CGRect {
        let (xCentre, yCentre) = translateToViewCoordinates(coords)
        return CGRect(x: xCentre - radius, y: yCentre - radius, width: diameter, height: diameter)
    }

    private func updateBubbleViewAt(row: Int, col: Int, to color: BubbleColor?) {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return
        }
        let bubbleView = getBubbleViewAt(row: row, col: col)
        bubbleView?.render(as: color)
    }

    func updateProjectileView() {
        guard let projectileModel = model.projectile else {
            return
        }

        projectileView?.uiView.frame = getProjectileFrameFor(projectileModel.coords)
        projectileView?.render(as: model.projectile?.color)
    }

    func render() {
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                let bubble = model.getBubbleAt(row: row, col: col)
                updateBubbleViewAt(row: row, col: col, to: bubble?.color)
            }
        }
        updateProjectileView()
    }

    private func translateToViewCoordinates(_ coords: (Double, Double)) -> (Double, Double) {
        return (viewCoordinateScaleFactor * coords.0, viewCoordinateScaleFactor * coords.1)
    }

    private var viewCoordinateScaleFactor: Double {
        return Double(uiView.frame.size.width)
    }

    private var diameter: Double {
        return viewCoordinateScaleFactor / Double(BUBBLES_PER_ROW)
    }
    private var radius: Double {
        return diameter / 2
    }
}
