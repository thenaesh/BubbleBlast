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

    @IBAction private func handlePan(_ sender: UIPanGestureRecognizer) {
        let viewVelocity = sender.velocity(in: bubbleGridView)
        guard viewVelocity.y < 0 && bubbleGridModel.projectile?.status == .ready else {
            return
        }

        let direction = bubbleGridView.translateFromViewCoordinates(viewVelocity).normalized
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
}


