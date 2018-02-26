//
//  PaletteView.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 11/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

typealias Selector = UIImageView
typealias Button = UILabel

class PaletteView {
    let uiView = UIView()
    private let parentView: UIView

    let redSelector, greenSelector, blueSelector, orangeSelector: Selector
    let eraseSelector: Selector

    let resetButton = Button()
    let startButton = Button()
    let saveButton = Button()
    let loadButton = Button()

    init(parentView: UIView) {
        self.parentView = parentView

        self.redSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-red"))
        self.greenSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-green"))
        self.blueSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-blue"))
        self.orangeSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-orange"))
        self.eraseSelector = UIImageView(image: #imageLiteral(resourceName: "erase"))

        resetButton.text = "RESET"
        startButton.text = "START"
        saveButton.text = "SAVE"
        loadButton.text = "LOAD"
    }

    func setupPalette() {
        loadPaletteBox()
        addAllSelectorsToPaletteView()
        addAllButtonsToPaletteView()
        constrainSelectors()
        constrainButtons()
    }

    func teardownPalette() {
        uiView.removeFromSuperview()
    }

    private func loadPaletteBox() {
        let paletteHeight = parentView.frame.size.height / 5
        let paletteWidth = parentView.frame.size.width

        uiView.frame = CGRect(x: 0, y: paletteHeight * 4, width: paletteWidth, height: paletteHeight)
        uiView.backgroundColor = .lightGray
        parentView.addSubview(uiView)
    }

    private func addAllSelectorsToPaletteView() {
        for selector in [redSelector, greenSelector, blueSelector, orangeSelector, eraseSelector] {
            selector.translatesAutoresizingMaskIntoConstraints = false
            uiView.addSubview(selector)
        }
        grayOutAllSelectors()
    }

    private func addAllButtonsToPaletteView() {
        for button in [resetButton, startButton, saveButton, loadButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            uiView.addSubview(button)
        }
    }

    private func constrainSelectors() {
        // all selectors' positions/dimensions defined relative to eraseSelector
        for selector in [redSelector, greenSelector, blueSelector, orangeSelector] {
            // ensure all selectors are in the same horizontal line
            selector.centerYAnchor.constraint(equalTo: eraseSelector.centerYAnchor).isActive = true
            // ensure all selectors are the same size
            selector.heightAnchor.constraint(equalTo: eraseSelector.heightAnchor).isActive = true
            selector.widthAnchor.constraint(equalTo: eraseSelector.widthAnchor).isActive = true
        }

        let height = uiView.frame.size.height
        let width = uiView.frame.size.width

        // ensure the selectors are circles
        eraseSelector.heightAnchor.constraint(equalTo: eraseSelector.widthAnchor).isActive = true
        // fix height of selectors
        eraseSelector.heightAnchor.constraint(equalToConstant: height / 3).isActive = true
        // prevent selectors from exceeding bounds of the palette
        eraseSelector.topAnchor.constraint(equalTo: uiView.topAnchor, constant: height / 10).isActive = true
        eraseSelector.bottomAnchor.constraint(lessThanOrEqualTo: uiView.bottomAnchor).isActive = true

        // set selectors' distance apart
        uiView.leadingAnchor.constraint(equalTo: redSelector.leadingAnchor, constant: -width / 20).isActive = true
        redSelector.trailingAnchor.constraint(equalTo: greenSelector.leadingAnchor, constant: -width / 20).isActive = true
        greenSelector.trailingAnchor.constraint(equalTo: blueSelector.leadingAnchor, constant: -width / 20).isActive = true
        blueSelector.trailingAnchor.constraint(lessThanOrEqualTo: orangeSelector.leadingAnchor, constant: -width / 20).isActive = true
        eraseSelector.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -width / 20).isActive = true
    }

    private func constrainButtons() {
        // all buttons' positions/dimentions defined relative to startButton
        for button in [resetButton, saveButton, loadButton] {
            // ensure all buttons are in the same horizontal line
            button.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).isActive = true
            // ensure all selectors are the same size
            button.heightAnchor.constraint(equalTo: startButton.heightAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: startButton.widthAnchor).isActive = true
        }

        let height = uiView.frame.size.height

        // ensure the buttons are rectangles with 4:1 aspect ratio
        startButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 4).isActive = true
        // fix the height of buttons
        startButton.heightAnchor.constraint(equalToConstant: height / 5).isActive = true
        // prevent buttons frome exceeding bounds of the palette or appearing above the selectors
        startButton.topAnchor.constraint(greaterThanOrEqualTo: eraseSelector.bottomAnchor)
        startButton.bottomAnchor.constraint(equalTo: uiView.bottomAnchor).isActive = true

        // set buttons' distance apart
        uiView.leadingAnchor.constraint(equalTo: resetButton.leadingAnchor).isActive = true
        resetButton.trailingAnchor.constraint(lessThanOrEqualTo: startButton.leadingAnchor).isActive = true
        startButton.trailingAnchor.constraint(lessThanOrEqualTo: saveButton.leadingAnchor).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: loadButton.leadingAnchor).isActive = true
        loadButton.trailingAnchor.constraint(equalTo: uiView.trailingAnchor).isActive = true
    }

    func getSelectorContaining(point: CGPoint) -> Selector? {
        for selector in [redSelector, greenSelector, blueSelector, orangeSelector, eraseSelector] where selector.frame.contains(point) {
            return selector
        }
        return nil
    }

    func getButtonContaining(point: CGPoint) -> Button? {
        for button in [resetButton, startButton, saveButton, loadButton] where button.frame.contains(point) {
            return button
        }
        return nil
    }

    func highlightSelector(selector: Selector) {
        guard [redSelector, greenSelector, blueSelector, orangeSelector, eraseSelector].contains(selector) else {
            fatalError("There are selector types that don't match any known Bubble model!")
        }

        grayOutAllSelectors()
        let fullyOpaqueAlphaLevel = CGFloat(1.0)
        selector.alpha = fullyOpaqueAlphaLevel
    }

    func grayOutAllSelectors() {
        for selector in [redSelector, greenSelector, blueSelector, orangeSelector, eraseSelector] {
            let mostlyTransparentAlphaLevel = CGFloat(0.25)
            selector.alpha = mostlyTransparentAlphaLevel
        }
    }

    func mapSelectorToModel(selector: Selector) -> BubbleColor? {
        switch selector {
        case redSelector:
            return .redBubble
        case greenSelector:
            return .greenBubble
        case blueSelector:
            return .blueBubble
        case orangeSelector:
            return .orangeBubble
        case eraseSelector:
            return nil
        default:
            fatalError("There are selector types that don't match any known Bubble model!")
        }
    }
}
