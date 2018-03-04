//
//  Audio.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 4/3/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation
import UIKit.NSDataAsset
import AVFoundation

enum SoundTypes {
    case MP3
    case WAV
}

extension SoundTypes {
    var avStringValue: String {
        switch self {
        case .MP3:
            return AVFileType.mp3.rawValue
        case .WAV:
            return AVFileType.wav.rawValue
        }
    }
}

enum SoundNames: String {
    case SAFMarch = "tentera-singapura"
    case DDLCTheme = "background_theme_ddlc"
    case Lose = "smb_mariodie"
    case Win = "smb_world_clear"
    case Shoot = "smb_jump-small"
    case Coin = "smb_coin"
    case Powerup = "smb_powerup"
    case Explosion = "bigbomb"
    case Zap = "zap"

    // for conveniently iterating across all sounds
    static let all: [SoundNames] = [
        .SAFMarch,
        .DDLCTheme,
        .Lose,
        .Win,
        .Shoot,
        .Coin,
        .Powerup,
        .Explosion,
        .Zap
    ]
}

extension SoundNames {
    var type: SoundTypes {
        switch self {
        case .SAFMarch:
            return .MP3
        case .DDLCTheme:
            return .MP3
        default:
            return .WAV
        }
    }
}

class Audio {
    enum AudioError: Error {
        case audioDataMissingFromBundle
        case playerFailedToLoad
    }
    
    private var players: [SoundNames: AVAudioPlayer] = [:]

    fileprivate init() {
        loadSoundsFromAssetBundle()
    }

    func loadSoundsFromAssetBundle() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            for soundName in SoundNames.all {
                try loadSound(soundName)
            }
        } catch let error {
            // sounds failing to load is not a fatal error since the game is still fully playable
            // just print a warning and carry on
            print("WARNING: \(error.localizedDescription)")
        }
    }

    func loadSound(_ soundName: SoundNames) throws {
        let soundType = soundName.type.avStringValue

        guard let sound = NSDataAsset(name: soundName.rawValue) else {
            throw AudioError.audioDataMissingFromBundle
        }

        guard let player = try? AVAudioPlayer(data: sound.data, fileTypeHint: soundType) else {
            throw AudioError.playerFailedToLoad
        }

        players[soundName] = player
    }

    func play(_ name: SoundNames, numLoops: Int = 0) {
        guard let player = players[name] else {
            return
        }

        player.numberOfLoops = numLoops
        player.currentTime = 0
        player.play()
    }

    func stop(_ name: SoundNames) {
        players[name]?.stop()
    }

    func playForever(_ name: SoundNames) {
        play(name, numLoops: -1)
    }

    func stopAll() {
        for (_, player) in players {
            player.stop()
        }
    }
}

// singleton, but only accessed from the view controllers
let audio = Audio()
