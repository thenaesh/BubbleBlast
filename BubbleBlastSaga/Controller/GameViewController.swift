//
//  GameViewController.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 28/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit
import PhysicsEngine

class GameViewController: BaseViewController {
    
    @IBOutlet var gameArea: UIView!

    var gridFile: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWithParentView(self.gameArea)
        // Do any additional setup after loading the view, typically from a nib.
        loadGridFromFileIfPossible()
        bubbleGridView.render()
        destroyFloatingBubbles()
        loadProjectile()
        bubbleGridView.setupProjectileView()
    }

    override func refresh(displayLink: CADisplayLink) {
        self.bubbleGridModel.simulate(dt: displayLink.targetTimestamp - displayLink.timestamp)
        self.handleLandingProjectile()
        self.performRenderHack(on: self.gameArea)
    }

    func loadGridFromFileIfPossible() {
        guard let gridFile = self.gridFile else {
            return
        }

        // if a file is specified, it should not be erroneous, otherwise it's a problem with our code
        // user error should be caught before this view controller is loaded
        guard bubbleGridModel.load(from: gridFile) else {
            fatalError("Bad load string specified!")
        }
    }

    /******************************
     ** Game Mode Input Handlers **
     ******************************/

    @IBAction private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let projectile = bubbleGridModel.projectile else {
            fatalError("Projectile missing!")
        }
        guard sender.state == .began else {
            return
        }

        let pressPosition = bubbleGridView.translateFromViewCoordinates(sender.location(in: bubbleGridView))
        let projectilePosition = projectile.position

        let direction = (pressPosition - projectilePosition).normalized
        guard direction.y < 0 && projectile.status == .ready else {
            return
        }

        launchProjectile(towards: direction)
    }

    /*****************************
     ** Game Mode Shot Handling **
     ******************************/

    func loadProjectile() {
        bubbleGridModel.destroyProjectile()
        bubbleGridModel.createProjectile()
    }

    func launchProjectile(towards direction: Vector2D) {
        let speed = 0.5
        let modelVelocity = speed * direction

        bubbleGridModel.projectile?.status = .flying
        bubbleGridModel.projectile?.velocity += modelVelocity
    }

    func handleLandingProjectile() {
        guard let projectile = bubbleGridModel.projectile else  {
            return
        }

        bubbleGridView.renderProjectile()

        guard projectile.status == .stopped else {
            return
        }

        let (row, col) = bubbleGridModel.nearestUnoccupiedGridPoint(from: projectile.position)
        bubbleGridModel.setBubbleAt(row: row, col: col, to: projectile.color)
        bubbleGridView.renderBubbleAt(row: row, col: col)

        performSpecialEffectsOnAdjacent(row: row, col: col)
        destroyAdjoiningCluster(row: row, col: col, of: projectile.color)
        destroyFloatingBubbles()

        loadProjectile() // reload
    }

    func destroyAdjoiningCluster(row: Int, col: Int, of color: BubbleColor) {
        let bubbleCluster = bubbleGridModel.getBubbleClusterAt(row: row, col: col, of: color)
        if bubbleCluster.count >= 3 {
            bubbleCluster.forEach({ (r, c) in
                self.bubbleGridModel.removeBubbleAt(row: r, col: c)
                self.bubbleGridView.renderBubbleWithAnimationAt(.fade, row: r, col: c)
            })
        }
    }

    func destroyFloatingBubbles() {
        bubbleGridModel.getFloatingBubbles().forEach({ (r, c) in
            self.bubbleGridModel.removeBubbleAt(row: r, col: c)
            self.bubbleGridView.renderBubbleWithAnimationAt(.drop, row: r, col: c)
        })
    }

    /*********************
     ** Special Bubbles **
     *********************/

    private func performSpecialEffectsOnAdjacent(row: Int, col: Int) {
        guard let triggeringBubble = bubbleGridModel.getBubbleAt(row: row, col: col) else {
            return
        }

        let adjSpecialBubbles = bubbleGridModel.getAdjacentTo(row: row, col: col).filter({ (r, c) in
            guard let bubble = self.bubbleGridModel.getBubbleAt(row: r, col: c) else {
                return false
            }
            return bubble.isSpecial()
        })

        for (r, c) in adjSpecialBubbles {
            performSpecialEffectsOnSelf(row: r, col: c, triggeringBubble: triggeringBubble)
        }
    }

    private func performSpecialEffectsOnSelf(row: Int, col: Int, triggeringBubble: Bubble?) {
        guard let bubble = bubbleGridModel.getBubbleAt(row: row, col: col) else {
            return
        }

        var bubblesToCascadeOn = [(Int, Int)]()

        switch bubble.color {
        case .lightningBubble:
            performLightningEffect(cascadeOn: &bubblesToCascadeOn, row: row)
        case .bombBubble:
            performBombEffect(cascadeOn: &bubblesToCascadeOn, row: row, col: col)
        case .starBubble:
            performStarEffect(color: triggeringBubble?.color)
        default:
            return
        }

        // destroy the special bubble itself
        bubbleGridModel.removeBubbleAt(row: row, col: col)
        self.bubbleGridView.renderBubbleWithAnimationAt(.fade, row: row, col: col)

        // cascade
        for (r, c) in bubblesToCascadeOn {
            performSpecialEffectsOnSelf(row: r, col: c, triggeringBubble: nil)
        }
    }

    private func performLightningEffect(cascadeOn: inout [(Int, Int)], row: Int) {
        let colsWithSpecialBubbles = (0..<BUBBLES_PER_ROW).filter({ (c) in
            guard let bubble = self.bubbleGridModel.getBubbleAt(row: row, col: c) else {
                return false
            }
            return bubble.isSpecial()
        })

        let colsWithStrikableBubbles = (0..<BUBBLES_PER_ROW).filter({ (c) in
            guard let bubble = self.bubbleGridModel.getBubbleAt(row: row, col: c) else {
                return false
            }
            return !(bubble.isSpecial() || bubble.color == .indestructibleBubble)
        })

        for c in colsWithStrikableBubbles {
            bubbleGridModel.removeBubbleAt(row: row, col: c)
            bubbleGridView.renderBubbleWithAnimationAt(.lightning, row: row, col: c)
        }

        cascadeOn = colsWithSpecialBubbles.map({ (c) in (row, c) })
    }

    private func performBombEffect(cascadeOn: inout [(Int, Int)], row: Int, col: Int) {
        let adjSpecialBubbles = bubbleGridModel.getAdjacentTo(row: row, col: col).filter({ (r, c) in
            guard let bubble = self.bubbleGridModel.getBubbleAt(row: r, col: c) else {
                return false
            }
            return bubble.isSpecial()
        })

        let adjBombableBubbles = bubbleGridModel.getAdjacentTo(row: row, col: col).filter({ (r, c) in
            guard let bubble = self.bubbleGridModel.getBubbleAt(row: r, col: c) else {
                return false
            }
            return !(bubble.isSpecial() || bubble.color == .indestructibleBubble)
        })

        for (r, c) in adjBombableBubbles {
            bubbleGridModel.removeBubbleAt(row: r, col: c)
            bubbleGridView.renderBubbleWithAnimationAt(.bomb, row: r, col: c)
        }

        cascadeOn = adjSpecialBubbles
    }

    private func performStarEffect(color: BubbleColor?) {
        guard let color = color else {
            return
        }

        let bubblesToRemove = bubbleGridModel.getAllBubblesSatisfying(condition: { (bubble) in bubble.color == color })

        for (r, c) in bubblesToRemove {
            bubbleGridModel.removeBubbleAt(row: r, col: c)
            bubbleGridView.renderBubbleWithAnimationAt(.star, row: r, col: c)
        }
    }
}


