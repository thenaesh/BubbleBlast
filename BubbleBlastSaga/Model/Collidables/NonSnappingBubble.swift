//
//  NonSnappingBubble.swift
//  BubbleBlastSaga
//
//  Created by Thenaesh Elango on 1/3/18.
//  Copyright © 2018 Thenaesh Elango. All rights reserved.
//

import Foundation
import PhysicsEngine

class NonSnappingBubble: Bubble, StickyCircle {
    // only magnetic bubbles have mass, so they can attract other bubbles
    var mass: Double? {
        return color == .magneticBubble ? 1 : nil
    }
    
    static var idCounter: Int64 = 0;
    static func getNewId() -> Int64 {
        idCounter += 1
        return idCounter
    }

    let id: Int64

    let adjacentGridBubbles: [(Int, Int)]
    let adjacentDanglingBubbles: Set<NonSnappingBubble>

    init(x: Double, y: Double, color: BubbleColor,
         adjacentGridBubbles: [(Int, Int)],
         adjacentDanglingBubbles: Set<NonSnappingBubble>) {
        self.id = NonSnappingBubble.getNewId()

        self.adjacentGridBubbles = adjacentGridBubbles
        self.adjacentDanglingBubbles = adjacentDanglingBubbles
        
        super.init(x: x, y: y, color: color)
    }

    required init(from decoder: Decoder) throws {
        fatalError("Cannot decode a NonSnappingBubble!")
    }

    override func encode(to encoder: Encoder) throws {
        fatalError("Cannot encode a NonSnappingBubble!")
    }

    func doOnCollide(with otherBody: inout DynamicBody) {
        guard let otherBody = otherBody as? ProjectileBubble else {
            return
        }

        otherBody.status = .stoppedWithoutSnapping
    }
}

extension NonSnappingBubble: Hashable {
    var hashValue: Int {
        return self.id.hashValue
    }

    static func ==(lhs: NonSnappingBubble, rhs: NonSnappingBubble) -> Bool {
        return lhs.id == rhs.id
    }
}
