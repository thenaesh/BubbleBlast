//
//  BubbleGridView.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 10/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class BubbleGridView: UIView {
    private let parentView: UIView
    private let model: BubbleGrid
    private var grid: [[BubbleView]] = []
    private var projectileView: BubbleView? = nil

    init(parentView: UIView, model: BubbleGrid) {
        self.parentView = parentView
        self.model = model
        super.init(frame: parentView.frame)
        attachGridViewToParent()
        fixAspectRatio()
        createBubbleGrid()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func attachGridViewToParent() {
        self.frame.size = parentView.frame.size
        parentView.addSubview(self)
    }

    private func fixAspectRatio() {
        let newHeight = (2 + Double(NUM_ROWS - 1) * sqrt(3)) * radius
        self.frame.size.height = CGFloat(newHeight)
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

    func setupProjectileView() {
        guard let projectileModel = model.projectile else {
            return
        }

        projectileView = BubbleView(frame: getProjectileFrameFor(projectileModel.position))

        guard let projectileView = projectileView else {
            fatalError("Projectile view failed to initialize!")
        }

        self.addSubview(projectileView)
    }

    func getBubbleIndexAt(coords: CGPoint) -> (Int, Int)? {
        // nil could be used instead, but that would introduce more checks later
        // this is automatically handled by the call to getBubbleAt(row: Int, col: Int) anyway
        let invalidIndex = -1

        var row: Int = invalidIndex
        var col: Int = invalidIndex

        for r in 0..<NUM_ROWS {
            for c in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: r, col: c) && grid[r][c].frame.contains(coords) {
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

    private func addBubbleToGrid(_ bubbleView: BubbleView) {
        self.addSubview(bubbleView)
    }

    private func getBubbleFrame(row: Int, col: Int) -> CGRect {
        let xCentre = (row % 2 == 0 ? 1 : 2) * radius + Double(col) * diameter
        let yCentre = radius + Double(row) * sqrt(3) * radius
        let xTopLeftCorner = xCentre - radius
        let yTopLeftCorner = yCentre - radius
        return CGRect(x: xTopLeftCorner, y: yTopLeftCorner, width: diameter, height: diameter)
    }

    func getProjectileFrameFor(_ coords: Vector2D) -> CGRect {
        let (xCentre, yCentre) = translateToViewCoordinates(coords)
        return CGRect(x: xCentre - radius, y: yCentre - radius, width: diameter, height: diameter)
    }

    func renderProjectile() {
        guard let projectileModel = model.projectile else {
            projectileView?.render(as: nil)
            return
        }

        projectileView?.frame = getProjectileFrameFor(projectileModel.position)
        projectileView?.render(as: model.projectile?.color)
    }

    func renderBubbleAt(row: Int, col: Int) {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return
        }

        let bubble = model.getBubbleAt(row: row, col: col)
        let bubbleView = getBubbleViewAt(row: row, col: col)
        bubbleView?.render(as: bubble?.color)
    }

    func renderBubbleWithAnimationAt(_ type: BubbleView.AnimationType, row: Int, col: Int) {
        guard isBubbleIndexAllowable(row: row, col: col) else {
            return
        }

        let bubble = model.getBubbleAt(row: row, col: col)
        let bubbleView = getBubbleViewAt(row: row, col: col)
        bubbleView?.renderWithAnimation(type, as: bubble?.color)
    }

    func render() {
        for row in 0..<NUM_ROWS {
            for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: row, col: col) {
                renderBubbleAt(row: row, col: col)
            }
        }
        renderProjectile()
    }

    func translateToViewCoordinates(_ coords: Vector2D) -> (Double, Double) {
        return (coords.x * viewCoordinateScaleFactor, coords.y * viewCoordinateScaleFactor)
    }

    func translateFromViewCoordinates(_ coords: CGPoint) -> Vector2D {
        let x = Double(coords.x)
        let y = Double(coords.y)
        return Vector2D(x, y) / viewCoordinateScaleFactor
    }

    private var viewCoordinateScaleFactor: Double {
        return Double(self.frame.size.width)
    }

    private var diameter: Double {
        return viewCoordinateScaleFactor / Double(BUBBLES_PER_ROW)
    }
    private var radius: Double {
        return diameter / 2
    }
}
