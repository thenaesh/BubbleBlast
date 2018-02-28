//
//  Constants.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 8/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import PhysicsEngine

let BUBBLES_PER_ROW = 12
let NUM_ROWS = 18
let NUM_ROWS_FOR_PALETTE = 9

func isBubbleIndexAllowable(row: Int, col: Int) -> Bool {
    guard 0 <= row && row < NUM_ROWS && 0 <= col else {
        return false
    }

    let evenRowCondition =  row % 2 == 0 && col < BUBBLES_PER_ROW
    let oddRowCondition = row % 2 == 1 && col < BUBBLES_PER_ROW - 1

    return evenRowCondition || oddRowCondition
}

func isBubbleIndexInPalette(row: Int, col: Int) -> Bool {
    guard isBubbleIndexAllowable(row: row, col: col) else {
        return false
    }

    return row < NUM_ROWS_FOR_PALETTE
}
