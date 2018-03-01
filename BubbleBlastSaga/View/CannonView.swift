//
//  CannonView.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 1/3/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit

class CannonView: UIView {
    let cannonSpriteSheet = #imageLiteral(resourceName: "cannon")

    let parentFrame: CGRect
    let projectileFrame: CGRect
    
    let cannonBase = UIImageView(image: #imageLiteral(resourceName: "cannon-base"))
    let cannonBarrel = UIImageView(image: nil)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentFrame: CGRect, projectileFrame: CGRect) {
        self.parentFrame = parentFrame
        self.projectileFrame = projectileFrame
        super.init(frame: parentFrame)
        loadCannonBase()
        //loadCannonBarrel()
    }

    private func loadCannonBase() {
        cannonBase.frame.size = projectileFrame.size
        cannonBase.frame.origin = projectileFrame.origin
        self.addSubview(cannonBase)
    }

    private func loadCannonBarrel() {
        let initialTile = getFromSpriteSheet(tile: 0)
        cannonBarrel.image = initialTile
        cannonBarrel.frame.size = cannonBase.frame.size
        cannonBarrel.frame.origin.x = cannonBase.frame.origin.x
        cannonBarrel.frame.origin.y = cannonBase.frame.origin.y - cannonBarrel.frame.height
        self.addSubview(cannonBarrel)
    }

    func getFromSpriteSheet(tile: Int) -> UIImage {
        guard 0 <= tile && tile < 12 else {
            fatalError("Attempted to access invalid tile")
        }

        let row = tile % 2
        let col = tile / 2

        let numRows = 2
        let numCols = 6

        let tileWidth = cannonSpriteSheet.size.width / CGFloat(numCols)
        let tileHeight = cannonSpriteSheet.size.height / CGFloat(numRows)

        let xPos = tileWidth * CGFloat(col)
        let yPos = tileHeight * CGFloat(row)

        let cropRect = CGRect(x: xPos, y: yPos, width: tileWidth, height: tileHeight)

        guard let tileCgImage = cannonSpriteSheet.cgImage?.cropping(to: cropRect) else {
            fatalError("Unable to get CGImage of spritesheet!")
        }

        return UIImage(cgImage: tileCgImage)
    }
}
