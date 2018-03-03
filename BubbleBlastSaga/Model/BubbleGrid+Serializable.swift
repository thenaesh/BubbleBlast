//
//  BubbleGrid+Serializable.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 11/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

extension BubbleGrid: Serializable {
    func save(to file: String) -> Bool {
        let jsonEncoder = JSONEncoder()
        guard let jsonData: Data = try? jsonEncoder.encode(self.grid) else {
            return false
        }
        saveData(jsonData, to: file)
        return true
    }

    func load(from file: String) -> Bool {
        let jsonDecoder = JSONDecoder()
        guard let jsonData: Data = loadData(from: file) else {
            return false
        }
        guard let decodedGrid: [[SnappingBubble?]] = try? jsonDecoder.decode([[SnappingBubble?]].self, from: jsonData) else {
            return false
        }
        self.grid = decodedGrid
        return true
    }
}
