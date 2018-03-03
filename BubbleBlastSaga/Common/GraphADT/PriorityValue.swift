//
//  PriorityValue.swift
//  GraphADT
//
//  Created by Thenaesh Elango on 28/1/18.
//  Copyright © 2018 NUS CS3217. All rights reserved.
//

struct PriorityValue<V> {
    let priority: Double
    let value: V
    
    init(_ priority: Double, _ value: V) {
        self.priority = priority
        self.value = value
    }
}

extension PriorityValue: Comparable {
    static func <(lhs: PriorityValue<V>, rhs: PriorityValue<V>) -> Bool {
        return lhs.priority < rhs.priority
    }
    
    static func ==(lhs: PriorityValue<V>, rhs: PriorityValue<V>) -> Bool {
        return lhs.priority == rhs.priority
    }
}
