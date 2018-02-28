//
//  BaseViewController.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 28/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupDisplayLink()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initWithParentView(_ view: UIView) {
        loadBackgroundImage(on: view)
        self.initializeBubbleGridModelAndView(on: view)
    }

    /******************************
     ** Bubble Grid Model & View **
     ******************************/

    private var _bubbleGridModel: BubbleGrid? = nil
    private var _bubbleGridView: BubbleGridView? = nil

    var bubbleGridModel: BubbleGrid {
        guard let __bubbleGridModel = self._bubbleGridModel else {
            fatalError("Uninitialized BubbbleGrid encountered at a point where it is expected to be initialized.")
        }
        return __bubbleGridModel
    }
    var bubbleGridView: BubbleGridView {
        guard let __bubbleGridView = self._bubbleGridView else {
            fatalError("Uninitialized BubbbleGridView encountered at a point where it is expected to be initialized.")
        }
        return __bubbleGridView
    }

    private func initializeBubbleGridModelAndView(on view: UIView) {
        self._bubbleGridModel = BubbleGrid()
        self._bubbleGridView = BubbleGridView(parentView: view, model: bubbleGridModel)
    }

    /******************
     ** Display Link **
     ******************/

    private var displayLink: CADisplayLink? = nil

    private func setupDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(refreshDisplayLink))
        self.displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
    }

    private func takedownDisplayLink() {
        self.displayLink?.remove(from: .current, forMode: .defaultRunLoopMode)
        self.displayLink = nil
    }

    @objc private func refreshDisplayLink(displayLink: CADisplayLink) {
        self.refresh(displayLink: displayLink)
    }

    func refresh(displayLink: CADisplayLink) {
        preconditionFailure("This method needs to be overriden!")
    }

    /***********************
     ** Utility Functions **
     ***********************/

    // There is some weird issue that delays updating UIImageViews, even if done on the main thread
    // Since the delay is only until the next UIImageView is updated,
    // we use a workaround of a tiny, rapidly-updating, nearly invisible bubble.
    private var renderingBugWorkaroundImage = UIImageView(image: #imageLiteral(resourceName: "bubble-red"))
    func performRenderHack(on view: UIView) {
        view.addSubview(self.renderingBugWorkaroundImage)
        self.renderingBugWorkaroundImage.alpha = 0.1
        self.renderingBugWorkaroundImage.frame.size.height = view.frame.size.height / 1000
        self.renderingBugWorkaroundImage.frame.size.width = view.frame.size.width / 1000
        if self.renderingBugWorkaroundImage.image == #imageLiteral(resourceName: "bubble-red") {
            self.renderingBugWorkaroundImage.image = #imageLiteral(resourceName: "bubble-blue")
        } else {
            self.renderingBugWorkaroundImage.image = #imageLiteral(resourceName: "bubble-red")
        }
    }

    func loadBackgroundImage(on view: UIView) {
        let backgroundImage = UIImage(named: "background.png")
        let background = UIImageView(image: backgroundImage)
        background.frame.size = view.frame.size
        view.addSubview(background)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.takedownDisplayLink()
    }
}
