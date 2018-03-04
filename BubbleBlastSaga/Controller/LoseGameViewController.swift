//
//  LoseGameGameViewController.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 3/3/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit

class LoseGameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        audio.stopAll()
        audio.play(.Lose)
        
        print("GAME OVER :(")
    }
}
