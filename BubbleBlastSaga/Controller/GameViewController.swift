//
//  GameViewController.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 28/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit
import PhysicsEngine
import AVFoundation

class GameViewController: BaseViewController {
    
    @IBOutlet var gameArea: UIView!

    var gridFile: String? = nil
    var player: AVAudioPlayer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWithParentView(self.gameArea)
        // Do any additional setup after loading the view, typically from a nib.
        loadGridFromFile()
        bubbleGridView.render()
        destroyFloatingBubbles()
        loadProjectile()
        bubbleGridView.setupProjectileView()

        func playSound(_ name: String) {
            guard let sound = NSDataAsset(name: name) else {
                print("url missing")
                return
            }

            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)

                player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.mp3.rawValue)

                guard let player = player else {
                    print("player failed to initialise")
                    return
                }

                player.numberOfLoops = -1
                player.play()

            } catch let error {
                print(error.localizedDescription)
            }
        }
        playSound("background_theme_mario")
    }

    override func refresh(displayLink: CADisplayLink) {
        self.bubbleGridModel.simulate(dt: displayLink.targetTimestamp - displayLink.timestamp)
        self.handleLandingProjectile()
        self.performRenderHack(on: self.gameArea)
    }

    func loadGridFromFile() {
        // if no file is specified, it's a problem with our code
        guard let gridFile = self.gridFile else {
            fatalError("No load string specified!")
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
        let speed = 1.0
        let modelVelocity = speed * direction

        bubbleGridModel.projectile?.isAnchored = false
        bubbleGridModel.projectile?.status = .flying
        bubbleGridModel.projectile?.velocity += modelVelocity
    }

    func handleLandingProjectile() {
        guard let projectile = bubbleGridModel.projectile else  {
            return
        }

        bubbleGridView.renderProjectile()

        guard projectile.status == .stopped || projectile.status == .stoppedWithoutSnapping else {
            return
        }

        /*
        if projectile.status == .stoppedWithoutSnapping || projectile.isNonSnapping {

            let adjGridBubbles = bubbleGridModel.getAdjacentTo(position: projectile.position)
            let adjDanglingBubbles = bubbleGridModel.danglingBubbles.filter({ (danglingBubble) in
                return (danglingBubble.position - projectile.position).magnitude <= Bubble.diameter
            })

            let newDanglingBubble = NonSnappingBubble(x: projectile.position.x,
                                                      y: projectile.position.y,
                                                      color: projectile.color,
                                                      adjacentGridBubbles: adjGridBubbles,
                                                      adjacentDanglingBubbles: adjDanglingBubbles)

            bubbleGridModel.danglingBubbles.insert(newDanglingBubble)

            // TODO: refactor this mess, this belongs in the view
            let viewCoords = bubbleGridView.translateToViewCoordinates(newDanglingBubble.position)
            bubbleGridView.danglingBubbleViews[newDanglingBubble.id] = BubbleView(frame: CGRect(x: viewCoords.0 - bubbleGridView.radius,
                                                                                                y: viewCoords.1 - bubbleGridView.radius,
                                                                                                width: bubbleGridView.diameter,
                                                                                                height: bubbleGridView.diameter))
            bubbleGridView.addSubview(bubbleGridView.danglingBubbleViews[newDanglingBubble.id]!)
            bubbleGridView.danglingBubbleViews[newDanglingBubble.id]?.render(as: newDanglingBubble.color)

        } else {

            let (row, col) = bubbleGridModel.nearestUnoccupiedGridPoint(from: projectile.position)
            bubbleGridModel.setBubbleAt(row: row, col: col, to: projectile.color)
            bubbleGridView.renderBubbleAt(row: row, col: col)

            performSpecialEffectsOnAdjacent(row: row, col: col)
            destroyAdjoiningCluster(row: row, col: col, of: projectile.color)
            destroyFloatingBubbles()

        }
        */

        let (row, col) = bubbleGridModel.nearestUnoccupiedGridPoint(from: projectile.position)

        bubbleGridModel.setBubbleAt(row: row, col: col, to: projectile.color)
        bubbleGridView.renderBubbleAt(row: row, col: col)

        performSpecialEffectsOnAdjacent(row: row, col: col)
        destroyAdjoiningCluster(row: row, col: col, of: projectile.color)
        destroyFloatingBubbles()

        winIfConditionSatisfied()
        loseIfConditionSatisfied()

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

    /***********************
     ** Win/Loss Handling **
     ***********************/

    func isGameWon() -> Bool {
        // we only need to check that the first row is empty
        // that means there is no bubble connected to the ceiling, so every bubble would have dropped off
        // this implies that the entire grid is empty, which is our win condition
        let firstRow = 0

        for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: firstRow, col: col) {
            guard bubbleGridModel.getBubbleAt(row: firstRow, col: col) == nil else {
                return false
            }
        }

        return true
    }

    func isGameLost() -> Bool {
        // if any bubbles are placed on this row, the game is lost
        // the rows below it are also automatically forbidden, since by ceiling connection requirement
        // if there is a bubble in any row below then there neccesarily is a bubble in this row as well
        let losingRow = NUM_ROWS - 2

        for col in 0..<BUBBLES_PER_ROW where isBubbleIndexAllowable(row: losingRow, col: col) {
            if bubbleGridModel.getBubbleAt(row: losingRow, col: col) != nil {
                return true
            }
        }

        return false
    }

    func winIfConditionSatisfied() {
        if isGameWon() {
            performSegue(withIdentifier: "winGame", sender: nil)
        }
    }

    func loseIfConditionSatisfied() {
        if isGameLost() {
            performSegue(withIdentifier: "loseGame", sender: nil)
        }
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


