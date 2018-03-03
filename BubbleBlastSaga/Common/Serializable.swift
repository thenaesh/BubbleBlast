//
//  SavableToFile.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 11/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

protocol Serializable {
    func save(to file: String) -> Bool
    func load(from file: String) -> Bool
}


/********************
 ** Helper Methods **
 ********************/

func saveData(_ data: Data, to file: String) {
    try? data.write(to: getFileURL(file))
}

func loadData(from file: String) -> Data? {
    return try? Data(contentsOf: getFileURL(file))
}

func getFileURL(_ file: String) -> URL {
    // Get the URL of the Documents Directory
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // Get the URL for a file in the Documents Directory
    let documentDirectory = urls[0]
    let fileURL = documentDirectory.appendingPathComponent(file)

    return fileURL
}
