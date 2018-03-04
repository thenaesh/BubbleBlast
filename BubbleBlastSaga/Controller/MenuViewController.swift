//
//  MenuViewController.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 4/3/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        audio.stopAll()
        audio.playForever(.DDLCTheme)
    }
}
