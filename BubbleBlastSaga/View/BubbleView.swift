//
//  BubbleView.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 10/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class BubbleView: UIImageView {
    enum AnimationType {
        case fade
        case drop
        case lightning
        case bomb
        case star
    }

    override init(frame: CGRect) {
        super.init(image: nil)
        self.frame = frame
        self.layer.cornerRadius = frame.size.width / 2
        self.isUserInteractionEnabled = true;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(to img: UIImage?) {
        self.image = img
        self.setNeedsDisplay()
    }

    func setBackground(to color: UIColor?) {
        self.backgroundColor = color
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
        case .indestructibleBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-indestructible"))
        case .lightningBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-lightning"))
        case .bombBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-bomb"))
        case .starBubble?:
            setImage(to: #imageLiteral(resourceName: "bubble-star"))
        default:
            setImage(to: nil)
        }
    }

    func renderWithAnimation(_ type: AnimationType, as color: BubbleColor?) {
        switch type {
        case .fade:
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.render(as: color)
                self.alpha = 1
            })
        case .drop:
            UIView.animate(withDuration: 1, delay: 0.25, animations: {
                self.alpha = 0
                self.frame.origin.y += 100
            }, completion: { _ in
                self.render(as: color)
                self.frame.origin.y -= 100
                self.alpha = 1
            })
        case .lightning:
            UIView.animate(withDuration: 0.1, animations: {
                self.render(as: .lightningBubble)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                    self.alpha = 0
                }, completion: { _ in
                    self.render(as: color)
                    self.alpha = 1
                })
            })
        case .bomb:
            UIView.animate(withDuration: 0.1, animations: {
                self.render(as: .bombBubble)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                    self.alpha = 0
                }, completion: { _ in
                    self.render(as: color)
                    self.alpha = 1
                })
            })
        case .star:
            UIView.animate(withDuration: 0.1, animations: {
                self.render(as: .starBubble)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                    self.alpha = 0
                }, completion: { _ in
                    self.render(as: color)
                    self.alpha = 1
                })
            })
        }
    }
}
