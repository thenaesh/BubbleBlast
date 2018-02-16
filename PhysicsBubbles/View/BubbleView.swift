//
//  BubbleView.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 10/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class BubbleView {
    let uiView = UIImageView()

    init(frame: CGRect) {
        self.uiView.frame = frame
        self.uiView.layer.cornerRadius = frame.size.width / 2
        self.uiView.isUserInteractionEnabled = true;
    }

    func setImage(to img: UIImage?) {
        uiView.image = img
    }

    func setBackground(to color: UIColor?) {
        uiView.backgroundColor = color
    }

    func render(as bubble: Bubble?) {
        switch bubble {
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
}
