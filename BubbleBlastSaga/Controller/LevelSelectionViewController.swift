//
//  LevelSelectionViewController.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 3/3/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import UIKit

class SaveGameCollectionCell: UICollectionViewCell {
    @IBOutlet weak var saveGameLabel: UILabel!
}

class LevelSelectionViewController: UIViewController {

    @IBOutlet weak var savedGrids: UICollectionView!
    let reuseIdentifier = "cell"

    var saveFiles: [String] = []
    var chosenSaveFileToLoad: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.writeBundledLevelsToSaveDirectory()
        self.saveFiles = getSaveFiles()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let gameVC = segue.destination as? GameViewController {
            gameVC.gridFile = chosenSaveFileToLoad
        }
    }

    func writeBundledLevelsToSaveDirectory() {
        let bundledLevelNames = ["Cables", "Magnets", "Stripes"]

        for bundledLevelName in bundledLevelNames {
            guard let levelData = NSDataAsset(name: bundledLevelName) else {
                print("WARNING: Bundled level missing!")
                continue
            }
            saveData(levelData.data, to: bundledLevelName)
        }
    }

    func getSaveFiles() -> [String] {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Missing saved files directory!")
        }

        guard let saveFileURLs = try? FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil) else {
            fatalError("Unable to access saved files directory!")
        }

        let saveFiles = saveFileURLs
            .map({ (saveFileURL) -> String in
                let regex = "/([^/]*)$"
                let saveFileString = String(describing: saveFileURL)
                guard let matchedString = self.matches(for: regex, in: saveFileString).first else {
                    fatalError("Unexpected error in file URL format!")
                }
                return String(matchedString.suffix(from: matchedString.index(after: matchedString.startIndex)))
            })

        return saveFiles
    }

    // obtained from https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

// the collection view was made with help of https://stackoverflow.com/questions/31735228/how-to-make-a-simple-collection-view-with-swift

extension LevelSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.saveFiles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SaveGameCollectionCell
        cell.saveGameLabel.text = self.saveFiles[indexPath.item]

        return cell
    }
}

extension LevelSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chosenSaveFileToLoad = saveFiles[indexPath.item]
        performSegue(withIdentifier: "startGameWithGridFile", sender: nil)
    }
}
