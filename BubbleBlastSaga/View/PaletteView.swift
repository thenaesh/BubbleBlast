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

class PaletteView: UIView {
    private let parentView: UIView

    let redSelector, greenSelector, blueSelector, orangeSelector: Selector
    let indestructibleSelector, lightningSelector, bombSelector, starSelector: Selector
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
        self.indestructibleSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-indestructible"))
        self.lightningSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-lightning"))
        self.bombSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-bomb"))
        self.starSelector = UIImageView(image: #imageLiteral(resourceName: "bubble-star"))

        resetButton.text = "RESET"
        startButton.text = "START"
        saveButton.text = "SAVE"
        loadButton.text = "LOAD"
        super.init(frame: parentView.frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPalette() {
        loadPaletteBox()
        addAllSelectorsToPaletteView()
        addAllButtonsToPaletteView()
        constrainSelectors()
        constrainButtons()
    }

    func teardownPalette() {
        self.removeFromSuperview()
    }

    private func loadPaletteBox() {
        let paletteHeight = parentView.frame.size.height / 5
        let paletteWidth = parentView.frame.size.width

        self.frame = CGRect(x: 0, y: paletteHeight * 4, width: paletteWidth, height: paletteHeight)
        self.backgroundColor = .lightGray
        parentView.addSubview(self)
    }

    private func addAllSelectorsToPaletteView() {
        for selector in selectors {
            selector.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(selector)
        }
        grayOutAllSelectors()
    }

    private func addAllButtonsToPaletteView() {
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(button)
        }
    }

    private func constrainSelectors() {
        // all selectors' positions/dimensions defined relative to eraseSelector
        for selector in selectors where selector != eraseSelector {
            // ensure all selectors are in the same horizontal line
            selector.centerYAnchor.constraint(equalTo: eraseSelector.centerYAnchor).isActive = true
            // ensure all selectors are the same size
            selector.heightAnchor.constraint(equalTo: eraseSelector.heightAnchor).isActive = true
            selector.widthAnchor.constraint(equalTo: eraseSelector.widthAnchor).isActive = true
        }

        let height = self.frame.size.height
        let width = self.frame.size.width

        // ensure the selectors are circles
        eraseSelector.heightAnchor.constraint(equalTo: eraseSelector.widthAnchor).isActive = true
        // fix height of selectors
        eraseSelector.heightAnchor.constraint(equalToConstant: height / 3).isActive = true
        // prevent selectors from exceeding bounds of the palette
        eraseSelector.topAnchor.constraint(equalTo: self.topAnchor, constant: height / 10).isActive = true
        eraseSelector.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor).isActive = true

        // set selectors' distance apart
        self.leadingAnchor.constraint(equalTo: redSelector.leadingAnchor, constant: -width / 50).isActive = true
        redSelector.trailingAnchor.constraint(equalTo: greenSelector.leadingAnchor).isActive = true
        greenSelector.trailingAnchor.constraint(equalTo: blueSelector.leadingAnchor).isActive = true
        blueSelector.trailingAnchor.constraint(lessThanOrEqualTo: orangeSelector.leadingAnchor).isActive = true
        orangeSelector.trailingAnchor.constraint(lessThanOrEqualTo: indestructibleSelector.leadingAnchor, constant: -width / 20).isActive = true
        indestructibleSelector.trailingAnchor.constraint(lessThanOrEqualTo: lightningSelector.leadingAnchor).isActive = true
        lightningSelector.trailingAnchor.constraint(lessThanOrEqualTo: bombSelector.leadingAnchor).isActive = true
        bombSelector.trailingAnchor.constraint(lessThanOrEqualTo: starSelector.leadingAnchor).isActive = true
        eraseSelector.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -width / 50).isActive = true
    }

    private func constrainButtons() {
        // all buttons' positions/dimentions defined relative to startButton
        for button in buttons where button != startButton {
            // ensure all buttons are in the same horizontal line
            button.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).isActive = true
            // ensure all selectors are the same size
            button.heightAnchor.constraint(equalTo: startButton.heightAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: startButton.widthAnchor).isActive = true
        }

        let height = self.frame.size.height

        // ensure the buttons are rectangles with 4:1 aspect ratio
        startButton.widthAnchor.constraint(equalTo: startButton.heightAnchor, multiplier: 4).isActive = true
        // fix the height of buttons
        startButton.heightAnchor.constraint(equalToConstant: height / 5).isActive = true
        // prevent buttons frome exceeding bounds of the palette or appearing above the selectors
        startButton.topAnchor.constraint(greaterThanOrEqualTo: eraseSelector.bottomAnchor)
        startButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        // set buttons' distance apart
        self.leadingAnchor.constraint(equalTo: resetButton.leadingAnchor).isActive = true
        resetButton.trailingAnchor.constraint(lessThanOrEqualTo: startButton.leadingAnchor).isActive = true
        startButton.trailingAnchor.constraint(lessThanOrEqualTo: saveButton.leadingAnchor).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: loadButton.leadingAnchor).isActive = true
        loadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    func getSelectorContaining(point: CGPoint) -> Selector? {
        for selector in selectors where selector.frame.contains(point) {
            return selector
        }
        return nil
    }

    func getButtonContaining(point: CGPoint) -> Button? {
        for button in buttons where button.frame.contains(point) {
            return button
        }
        return nil
    }

    func highlightSelector(selector: Selector) {
        guard selectors.contains(selector) else {
            fatalError("There are selector types that don't match any known Bubble model!")
        }

        grayOutAllSelectors()
        let fullyOpaqueAlphaLevel = CGFloat(1.0)
        selector.alpha = fullyOpaqueAlphaLevel
    }

    func grayOutAllSelectors() {
        for selector in selectors {
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
        case indestructibleSelector:
            return .indestructibleBubble
        case lightningSelector:
            return .lightningBubble
        case bombSelector:
            return .bombBubble
        case starSelector:
            return .starBubble
        case eraseSelector:
            return nil
        default:
            fatalError("There are selector types that don't match any known Bubble model!")
        }
    }

    var selectors: [Selector] {
        return [redSelector,
                greenSelector,
                blueSelector,
                orangeSelector,
                indestructibleSelector,
                lightningSelector,
                bombSelector,
                starSelector,
                eraseSelector]
    }

    var buttons: [Button] {
        return [resetButton, startButton, saveButton, loadButton]
    }
}
