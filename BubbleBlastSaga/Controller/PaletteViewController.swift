//
//  PaletteViewController.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 1/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class PaletteViewController: GridViewController {
    
    @IBOutlet var gameArea: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWithParentView(self.gameArea)
        // Do any additional setup after loading the view, typically from a nib.
        createPalette()
    }

    override func refresh(displayLink: CADisplayLink) {
        self.bubbleGridView.render()
        self.performRenderHack(on: self.gameArea)
    }
    
    private var _paletteView: PaletteView? = nil
    private var paletteView: PaletteView {
        guard let __paletteView = self._paletteView else {
            fatalError("Uninitialized PaletteView encountered at a point where it is expected to be initialized.")
        }
        return __paletteView
    }

    private var nextBubbleToDraw: BubbleColor? = nil

    /**********************
     ** Palette Creation **
     **********************/

    private func createPalette() {
        self._paletteView = PaletteView(parentView: gameArea)
        paletteView.setupPalette()
        markBubblesInPaletteGrid(with: .gray)
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

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let coords = sender.location(in: gameArea)

        if didTapOccurInPaletteRegion(at: coords) {
            let paletteCoords = sender.location(in: paletteView)
            handleTapInPaletteRegion(at: paletteCoords)
        } else {
            let bubbleGridCoords = sender.location(in: bubbleGridView)
            handleTapInGridRegion(at: bubbleGridCoords)
        }
    }
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let bubbleGridCoords = sender.location(in: bubbleGridView)
        handlePanInGridRegion(at: bubbleGridCoords)
    }
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        let bubbbleGridCoords = sender.location(in: bubbleGridView)
        handleLongPressInGridRegion(at: bubbbleGridCoords)
    }

    /* handle taps in the bottom part of the screen where the palette itself is located */

    private func didTapOccurInPaletteRegion(at coords: CGPoint) -> Bool {
        return paletteView.frame.contains(coords)
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

    /*************************
     ** File Saving/Loading **
     *************************/

    private func promptUserForSave() {
        self.promptUser(title: "Save Bubble Configuration", message: "Enter file to save to", action: { (alert) in
            return UIAlertAction(title: "Save", style: .default) { (alertAction) in
                let textField = alert.textFields![0] as UITextField

                guard let filename: String = textField.text else {
                    return
                }

                guard self.isFileNameLegal(filename) else {
                    self.alertUser(title: "ERROR", message: "Invalid filename. Only alphanumerics are allowed.")
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

                guard self.isFileNameLegal(filename) else {
                    self.alertUser(title: "ERROR", message: "Invalid filename. Only alphanumerics are allowed.")
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
            textField.placeholder = "<filename>"
        }
        alert.addAction(action(alert))
        self.present(alert, animated:true, completion: nil)
    }

    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .`default`))
        self.present(alert, animated: true, completion: nil)
    }

    // only alphanumerics allowed in save file names
    private func isFileNameLegal(_ filename: String) -> Bool {
        return CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: filename))
    }

    /*********************
     ** Game Mode Segue **
     *********************/

    private let defaultGridFile = "PreviousLevel"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard self.bubbleGridModel.save(to: defaultGridFile) else {
            fatalError("Unable to save to \(defaultGridFile)!")
        }

        if let gameVC = segue.destination as? GameViewController {
            gameVC.gridFile = defaultGridFile
        }
    }

    func switchToGameMode() {
        self.performSegue(withIdentifier: "switchToGameMode", sender: nil)
    }
}

