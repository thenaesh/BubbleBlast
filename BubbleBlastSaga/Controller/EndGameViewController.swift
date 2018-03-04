//
//  EndGameViewController.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 4/3/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit

enum EndGameState {
    case Win
    case Lose
}

class EndGameViewController: UIViewController {

    @IBOutlet weak var message: UILabel!

    @IBOutlet weak var redScoreField: UILabel!
    @IBOutlet weak var greenScoreField: UILabel!
    @IBOutlet weak var blueScoreField: UILabel!
    @IBOutlet weak var orangeScoreField: UILabel!
    @IBOutlet weak var specialScoreField: UILabel!
    
    var endState: EndGameState? = nil
    var score: [BubbleColor: Int]? = nil
    var specialScore: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupEndMessageAndAudio()
        showScores()
    }

    func setupEndMessageAndAudio() {
        guard let endState = self.endState else {
            fatalError("End state not passed to end game controller!")
        }

        audio.stopAll()

        switch endState {
        case .Win:
            audio.play(.Win)
            message.text = "You Win"
        case .Lose:
            audio.play(.Lose)
            message.text = "You Lose"
        }
    }

    func showScores() {
        guard let score = self.score,
              let redScore = score[.redBubble],
              let greenScore = score[.greenBubble],
              let blueScore = score[.blueBubble],
              let orangeScore = score[.orangeBubble],
              let specialScore = self.specialScore else {
            fatalError("Scores not passed to end game controller!")
        }

        redScoreField.text = String(redScore)
        greenScoreField.text = String(greenScore)
        blueScoreField.text = String(blueScore)
        orangeScoreField.text = String(orangeScore)
        specialScoreField.text = String(specialScore)
    }
}
