//
//  BubbleView.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 10/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class BubbleView {
    enum AnimationType {
        case fade
        case drop
    }

    let uiView = UIImageView()

    init(frame: CGRect) {
        self.uiView.frame = frame
        self.uiView.layer.cornerRadius = frame.size.width / 2
        self.uiView.isUserInteractionEnabled = true;
    }

    func setImage(to img: UIImage?) {
        uiView.image = img
        uiView.setNeedsDisplay()
    }

    func setBackground(to color: UIColor?) {
        uiView.backgroundColor = color
    }

    func render(as color: BubbleColor?) {
        switch color {
        case .redBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-red"))
        case .greenBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-green"))
        case .blueBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-blue"))
        case .orangeBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-orange"))
        default:
            setImage(to: nil)
        }
    }

    func renderWithAnimation(_ type: AnimationType, as color: BubbleColor?) {
        switch type {
        case .fade:
            UIView.animate(withDuration: 0.5, animations: {
                self.uiView.alpha = 0
            }, completion: { _ in
                self.render(as: color)
                self.uiView.alpha = 1
            })
        case .drop:
            UIView.animate(withDuration: 1, delay: 0.25, animations: {
                self.uiView.alpha = 0
                self.uiView.frame.origin.y += 100
            }, completion: { _ in
                self.render(as: color)
                self.uiView.frame.origin.y -= 100
                self.uiView.alpha = 1
            })
        }
    }
}
