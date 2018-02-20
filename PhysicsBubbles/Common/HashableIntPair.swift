//
//  HashableIntPair.swift
//  PhysicsBubbles
//
//  Created by Thenaesh Elango on 20/2/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation

/*
 * For when we need a hashable (Int, Int).
 */
struct HashableIntPair: Hashable {
    var hashValue: Int {
        let fnvConstant = 16777619
        return self.pair.0.hashValue ^ self.pair.1.hashValue &* fnvConstant
    }

    static func ==(lhs: HashableIntPair, rhs: HashableIntPair) -> Bool {
        return lhs.pair == rhs.pair
    }

    let pair: (Int, Int)

    init(_ first: Int, _ second: Int) {
        self.pair = (first, second)
    }

    init(_ pair: (Int, Int)) {
        self.pair = pair
    }
}
