//
//  ViewController.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 1/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var gameArea: UIView!
    private var _bubbleGridModel: BubbleGrid? = nil

    private var _bubbleGridView: BubbleGridView? = nil
    private var _paletteView: PaletteView? = nil

    private var nextBubbleToDraw: BubbleColor? = nil
    private var displayLink: CADisplayLink? = nil

    private var bubbleGridModel: BubbleGrid {
        guard let __bubbleGridModel = self._bubbleGridModel else {
            fatalError("Uninitialized BubbbleGrid encountered at a point where it is expected to be initialized.")
        }
        return __bubbleGridModel
    }
    private var bubbleGridView: BubbleGridView {
        guard let __bubbleGridView = self._bubbleGridView else {
            fatalError("Uninitialized BubbbleGridView encountered at a point where it is expected to be initialized.")
        }
        return __bubbleGridView
    }
    private var paletteView: PaletteView {
        guard let __paletteView = self._paletteView else {
            fatalError("Uninitialized PaletteView encountered at a point where it is expected to be initialized.")
        }
        return __paletteView
    }

    @IBAction func handleGesture(_ sender: UIGestureRecognizer) {
        switch sender {
        case is UITapGestureRecognizer:
            _paletteView == nil ? gameModeTapHandler(sender as! UITapGestureRecognizer) : paletteModeTapHandler(sender as! UITapGestureRecognizer)
        case is UIPanGestureRecognizer:
            _paletteView == nil ? gameModePanHandler(sender as! UIPanGestureRecognizer) : paletteModePanHandler(sender as! UIPanGestureRecognizer)
        case is UILongPressGestureRecognizer:
            _paletteView == nil ? gameModeLongPressHandler(sender as! UILongPressGestureRecognizer) : paletteModeLongPressHandler(sender as! UILongPressGestureRecognizer)
        default:
            fatalError("Unexpected input handlers encountered!")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadBackgroundImage()
        initializeBubbleGridModelAndView()
        createPalette()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func loadBackgroundImage() {
        let backgroundImage = UIImage(named: "background.png")
        let background = UIImageView(image: backgroundImage)
        background.frame.size = gameArea.frame.size
        gameArea.addSubview(background)
    }

    private func initializeBubbleGridModelAndView() {
        self._bubbleGridModel = BubbleGrid()
        self._bubbleGridView = BubbleGridView(parentView: gameArea, model: bubbleGridModel)
    }

    // There is some weird issue that delays updating UIImageViews, even if done on the main thread
    // Since the delay is only until the next UIImageView is updated,
    // we use a workaround of a tiny, rapidly-updating, nearly invisible bubble.
    private var renderingBugWorkaroundImage = UIImageView(image: #imageLiteral(resourceName: "bubble-red"))
    private func performRenderHack() {
        self.gameArea.addSubview(self.renderingBugWorkaroundImage)
        self.renderingBugWorkaroundImage.alpha = 0.1
        self.renderingBugWorkaroundImage.frame.size.height = self.gameArea.frame.size.height / 1000
        self.renderingBugWorkaroundImage.frame.size.width = self.gameArea.frame.size.width / 1000
        if self.renderingBugWorkaroundImage.image == #imageLiteral(resourceName: "bubble-red") {
            self.renderingBugWorkaroundImage.image = #imageLiteral(resourceName: "bubble-blue")
        } else {
            self.renderingBugWorkaroundImage.image = #imageLiteral(resourceName: "bubble-red")
        }
    }

    /***************************
     ** Display Link Handlers **
     ***************************/

    private func takedownDisplayLink() {
        self.displayLink?.remove(from: .current, forMode: .defaultRunLoopMode)
        self.displayLink = nil
    }

    private func setupPaletteDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(refreshForPalette))
        self.displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
    }

    @objc private func refreshForPalette(displayLink: CADisplayLink) {
        self.bubbleGridView.render()
        self.performRenderHack()
    }

    private func setupGameDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(refreshForGame))
        self.displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
    }

    @objc private func refreshForGame(displayLink: CADisplayLink) {
        self.bubbleGridModel.simulate(dt: displayLink.targetTimestamp - displayLink.timestamp)
        self.handleLandingProjectile()
        self.performRenderHack()
    }

    /**************************************
     ** Palette Creation and Destruction **
     **************************************/

    private func createPalette() {
        self._paletteView = PaletteView(parentView: gameArea)
        paletteView.setupPalette()
        markBubblesInPaletteGrid(with: .gray)
        setupPaletteDisplayLink()
    }

    private func destroyPalette() {
        takedownDisplayLink()
        markBubblesInPaletteGrid(with: nil)
        paletteView.teardownPalette()
        self._paletteView = nil
    }


    private func markBubblesInPaletteGrid(with color: UIColor?) {
        for row in 0..<NUM_ROWS_FOR_PALETTE {
            for col in 0..<BUBBLES_PER_ROW {
                bubbleGridView.getBubbleViewAt(row: row, col: col)?.setBackground(to: color)
            }
        }
    }

    /*********************************
     ** Palette Mode Input Handlers **
     *********************************/

    private func paletteModeTapHandler(_ sender: UITapGestureRecognizer) {
        let coords = sender.location(in: gameArea)

        if didTapOccurInPaletteRegion(at: coords) {
            let paletteCoords = sender.location(in: paletteView.uiView)
            handleTapInPaletteRegion(at: paletteCoords)
        } else {
            let bubbleGridCoords = sender.location(in: bubbleGridView.uiView)
            handleTapInGridRegion(at: bubbleGridCoords)
        }
    }
    private func paletteModePanHandler(_ sender: UIPanGestureRecognizer) {
        let bubbleGridCoords = sender.location(in: bubbleGridView.uiView)
        handlePanInGridRegion(at: bubbleGridCoords)
    }
    private func paletteModeLongPressHandler(_ sender: UILongPressGestureRecognizer) {
        let bubbbleGridCoords = sender.location(in: bubbleGridView.uiView)
        handleLongPressInGridRegion(at: bubbbleGridCoords)
    }

    /* handle taps in the bottom part of the screen where the palette itself is located */

    private func didTapOccurInPaletteRegion(at coords: CGPoint) -> Bool {
        return paletteView.uiView.frame.contains(coords)
    }

    private func handleTapInPaletteRegion(at coords: CGPoint) {
        if let selector = paletteView.getSelectorContaining(point: coords) {
            handleTapOnPaletteSelector(selector: selector)
        } else if let button = paletteView.getButtonContaining(point: coords) {
            handleTapOnPaletteButton(button: button)
        }
    }

    private func handleTapOnPaletteSelector(selector: Selector) {
        nextBubbleToDraw = paletteView.mapSelectorToModel(selector: selector)
        paletteView.highlightSelector(selector: selector)
    }

    private func handleTapOnPaletteButton(button: Button) {
        switch button {
        case paletteView.resetButton:
            bubbleGridModel.removeAllBubbles()
            bubbleGridView.render()
        case paletteView.startButton:
            switchToGameMode()
        case paletteView.saveButton:
            promptUserForSave()
        case paletteView.loadButton:
            promptUserForLoad()
        default:
            fatalError("Bug in PaletteView.getButtonContaining, unexpected values returned")
        }
    }

    /* handle gestures in the top part of the screen where the bubble grid for painting on is located */

    private func handleTapInGridRegion(at coords: CGPoint) {
        guard let (row, col) = bubbleGridView.getBubbleIndexAt(coords: coords) else {
            return
        }

        guard isBubbleIndexInPalette(row: row, col: col) else {
            return
        }

        guard let nextBubble = nextBubbleToDraw else {
            bubbleGridModel.removeBubbleAt(row: row, col: col)
            return
        }

        guard let currentBubble = bubbleGridModel.getBubbleAt(row: row, col: col) else {
            bubbleGridModel.setBubbleAt(row: row, col: col, to: nextBubble)
            return
        }

        // cycling of filled bubbles
        bubbleGridModel.setBubbleAt(row: row, col: col, to: currentBubble.color.next())
    }

    private func handlePanInGridRegion(at coords: CGPoint) {
        guard let (row, col) =  bubbleGridView.getBubbleIndexAt(coords: coords) else {
            return
        }

        guard isBubbleIndexInPalette(row: row, col: col) else {
            return
        }

        guard let nextBubble = nextBubbleToDraw else {
            bubbleGridModel.removeBubbleAt(row: row, col: col)
            return
        }

        bubbleGridModel.setBubbleAt(row: row, col: col, to: nextBubble)
    }

    private func handleLongPressInGridRegion(at coords: CGPoint) {
        guard let (row, col) =  bubbleGridView.getBubbleIndexAt(coords: coords) else {
            return
        }

        guard isBubbleIndexInPalette(row: row, col: col) else {
            return
        }

        bubbleGridModel.removeBubbleAt(row: row, col: col)
    }

    /**************************************
     ** Palette Mode File Saving/Loading **
     **************************************/

    private func promptUserForSave() {
        self.promptUser(title: "Save Bubble Configuration", message: "Enter file to save to", action: { (alert) in
            return UIAlertAction(title: "Save", style: .default) { (alertAction) in
                let textField = alert.textFields![0] as UITextField

                guard let filename: String = textField.text else {
                    return
                }

                let success = self.bubbleGridModel.save(to: filename)

                if !success {
                    self.alertUser(title: "ERROR", message: "Could not save to \(filename).")
                }
            }
        })
    }

    private func promptUserForLoad() {
        self.promptUser(title: "Load Bubble Configuration", message: "Enter file to load from", action: { (alert) in
            return UIAlertAction(title: "Load", style: .default) { (alertAction) in
                let textField = alert.textFields![0] as UITextField

                guard let filename: String = textField.text else {
                    return
                }

                let success = self.bubbleGridModel.load(from: filename)

                if !success {
                    self.alertUser(title: "ERROR", message: "Could not load from \(filename).")
                }
            }
        })
    }

    private func promptUser(title: String, message: String, action: (UIAlertController) -> UIAlertAction) {
        // implementation obtained from https://medium.com/@chan.henryk/alert-controller-with-text-field-in-swift-3-bda7ac06026c
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "<filename>.json"
        }
        alert.addAction(action(alert))
        self.present(alert, animated:true, completion: nil)
    }

    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .`default`))
        self.present(alert, animated: true, completion: nil)
    }

    /*********************
     ** Game Mode Setup **
     *********************/

    func switchToGameMode() {
        destroyPalette()
        setupGameDisplayLink()
        loadProjectile()
        bubbleGridView.setupProjectileView()
    }

    /******************************
     ** Game Mode Input Handlers **
     ******************************/

    private func gameModeTapHandler(_ sender: UITapGestureRecognizer) {
    }
    private func gameModePanHandler(_ sender: UIPanGestureRecognizer) {
        let viewVelocity = sender.velocity(in: bubbleGridView.uiView)
        guard viewVelocity.y < 0 && bubbleGridModel.projectile?.status == .ready else {
            return
        }

        let direction = bubbleGridView.translateFromViewCoordinates(viewVelocity).normalized
        launchProjectile(towards: direction)
    }
    private func gameModeLongPressHandler(_ sender: UILongPressGestureRecognizer) {
    }

    /**********************************
     ** Game Mode Shot Handling Code **
     **********************************/

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

