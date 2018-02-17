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
    private var nextBubbleToDraw: Bubble? = nil
    private var renderingBugWorkaroundImage = UIImageView(image: #imageLiteral(resourceName: "bubble-red"))

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
        setupDisplayLink()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(refresh))
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        initRenderHack()
    }

    @objc private func refresh(displayLink: CADisplayLink) {
        DispatchQueue.main.async {
            self.bubbleGridView.render()
            self.performRenderHack()
        }
    }

    private func initRenderHack() {
        self.gameArea.addSubview(self.renderingBugWorkaroundImage)
        self.renderingBugWorkaroundImage.alpha = 0.1
        self.renderingBugWorkaroundImage.frame.size.height = self.gameArea.frame.size.height / 1000
        self.renderingBugWorkaroundImage.frame.size.width = self.gameArea.frame.size.width / 1000
    }

    private func performRenderHack() {
        if self.renderingBugWorkaroundImage.image == #imageLiteral(resourceName: "bubble-red") {
            self.renderingBugWorkaroundImage.image = #imageLiteral(resourceName: "bubble-blue")
        } else {
            self.renderingBugWorkaroundImage.image = #imageLiteral(resourceName: "bubble-red")
        }
        self.bubbleGridView.render()
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

    private func createPalette() {
        self._paletteView = PaletteView(parentView: gameArea)
        paletteView.setupPalette()
        markPaintableBubbles(with: .gray)
    }

    private func destroyPalette() {
        markPaintableBubbles(with: nil)
        paletteView.teardownPalette()
        self._paletteView = nil
    }

    private func markPaintableBubbles(with color: UIColor?) {
        for row in 0..<NUM_ROWS_FOR_PALETTE {
            for col in 0..<BUBBLES_PER_ROW {
                bubbleGridView.getBubbleViewAt(row: row, col: col)?.setBackground(to: color)
            }
        }
    }

    /*******************************
     ** Input Handlers for Scenes **
     *******************************/

    private func paletteModeTapHandler(_ sender: UITapGestureRecognizer) {
        let coords = sender.location(in: gameArea)

        if didTapOccurInPalette(at: coords) {
            let paletteCoords = sender.location(in: paletteView.uiView)
            handlePaletteTap(at: paletteCoords)
        } else {
            let bubbleGridCoords = sender.location(in: bubbleGridView.uiView)
            handleGridTap(at: bubbleGridCoords)
        }
    }
    private func paletteModePanHandler(_ sender: UIPanGestureRecognizer) {
        let bubbleGridCoords = sender.location(in: bubbleGridView.uiView)
        handleGridPan(at: bubbleGridCoords)
    }
    private func paletteModeLongPressHandler(_ sender: UILongPressGestureRecognizer) {
        let bubbbleGridCoords = sender.location(in: bubbleGridView.uiView)
        handleGridLongPress(at: bubbbleGridCoords)
    }

    private func gameModeTapHandler(_ sender: UITapGestureRecognizer) {
        print("Tap @ \(sender.location(in: gameArea))")
    }
    private func gameModePanHandler(_ sender: UIPanGestureRecognizer) {
        print("Pan @ \(sender.location(in: gameArea))")
    }
    private func gameModeLongPressHandler(_ sender: UILongPressGestureRecognizer) {
        print("Long Press @ \(sender.location(in: gameArea))")
    }


    /**********************************************
     ** Code to handle user input in the palette **
     **********************************************/

    private func didTapOccurInPalette(at coords: CGPoint) -> Bool {
        return paletteView.uiView.frame.contains(coords)
    }

    private func handlePaletteTap(at coords: CGPoint) {
        if let selector = paletteView.getSelectorContaining(point: coords) {
            handlePaletteSelectorTap(selector: selector)
        } else if let button = paletteView.getButtonContaining(point: coords) {
            handlePaletteButtonTap(button: button)
        }
    }

    private func handlePaletteSelectorTap(selector: Selector) {
        nextBubbleToDraw = paletteView.mapSelectorToModel(selector: selector)
        paletteView.highlightSelector(selector: selector)
    }

    private func handlePaletteButtonTap(button: Button) {
        switch button {
        case paletteView.resetButton:
            bubbleGridModel.setAllBubbles(to: nil)
            bubbleGridView.render()
        case paletteView.startButton:
            // TODO: implement this in a future PS
            //print("start button tapped")
            destroyPalette()
        case paletteView.saveButton:
            promptUserForSave()
        case paletteView.loadButton:
            promptUserForLoad()
        default:
            fatalError("Bug in PaletteView.getButtonContaining, unexpected values returned")
        }
    }

    /**************************************************
     ** Code to handle user input in the bubble grid **
     **************************************************/

    private func handleGridTap(at coords: CGPoint) {
        guard let (row, col) = bubbleGridView.getBubbleIndexAt(coords: coords) else {
            return
        }

        guard isBubbleIndexInPalette(row: row, col: col) else {
            return
        }

        guard let currentBubble = bubbleGridModel.getBubbleAt(row: row, col: col) else {
            bubbleGridModel.setBubbleAt(row: row, col: col, to: nextBubbleToDraw)
            return
        }

        // cycling of filled bubbles
        if nextBubbleToDraw == nil {
            bubbleGridModel.setBubbleAt(row: row, col: col, to: nextBubbleToDraw)
        } else {
            bubbleGridModel.setBubbleAt(row: row, col: col, to: currentBubble.next())
        }
    }

    private func handleGridPan(at coords: CGPoint) {
        guard let (row, col) =  bubbleGridView.getBubbleIndexAt(coords: coords) else {
            return
        }

        guard isBubbleIndexInPalette(row: row, col: col) else {
            return
        }

        bubbleGridModel.setBubbleAt(row: row, col: col, to: nextBubbleToDraw)
    }

    private func handleGridLongPress(at coords: CGPoint) {
        guard let (row, col) =  bubbleGridView.getBubbleIndexAt(coords: coords) else {
            return
        }

        guard isBubbleIndexInPalette(row: row, col: col) else {
            return
        }

        bubbleGridModel.setBubbleAt(row: row, col: col, to: nil)
    }

    /************************************************************************************
     ** Code to handle saving and loading, including prompting the user for a filename **
     ************************************************************************************/

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
}

