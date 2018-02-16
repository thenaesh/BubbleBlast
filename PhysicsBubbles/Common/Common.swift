//
//  Constants.swift
//  LevelDesigner
//
//  Created by Thenaesh Elango on 8/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

let BUBBLES_PER_ROW = 12
let NUM_ROWS = 9
let NUM_ROWS_FOR_PALETTE = 18

func isBubbleIndexAllowable(row: Int, col: Int) -> Bool {
    guard 0 <= row && row < NUM_ROWS && 0 <= col else {
        return false
    }

    let evenRowCondition =  row % 2 == 0 && col < BUBBLES_PER_ROW
    let oddRowCondition = row % 2 == 1 && col < BUBBLES_PER_ROW - 1

    return evenRowCondition || oddRowCondition
}
