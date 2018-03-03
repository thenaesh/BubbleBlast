// Copyright (c) 2018 NUS CS3217. All rights reserved.

/**
 A generic `Stack` class whose elements are last-in, first-out.

 - Authors: CS3217
 - Date: 2018
 */
struct Stack<T> {
    var underlying_list: [T]
    
    init() {
        self.underlying_list = [T]()
    }

    /// Adds an element to the top of the stack.
    /// - Parameter item: The element to be added to the stack
    mutating func push(_ item: T) {
        self.underlying_list.append(item)
    }

    /// Removes the element at the top of the stack and return it.
    /// - Returns: element at the top of the stack
    mutating func pop() -> T? {
        // TODO: Replace/remove the following line in your implementation.
        return self.underlying_list.popLast()
    }

    /// Returns, but does not remove, the element at the top of the stack.
    /// - Returns: element at the top of the stack
    func peek() -> T? {
        // TODO: Replace/remove the following line in your implementation.
        guard !self.underlying_list.isEmpty else {
            return nil
        }
        let lastIndex = self.underlying_list.count - 1
        return self.underlying_list[lastIndex]
    }

    /// The number of elements currently in the stack.
    var count: Int {
        // TODO: Replace/remove the following line in your implementation.
        return self.underlying_list.count
    }

    /// Whether the stack is empty.
    var isEmpty: Bool {
        // TODO: Replace/remove the following line in your implementation.
        return self.underlying_list.isEmpty
    }

    /// Removes all elements in the stack.
    mutating func removeAll() {
        return self.underlying_list.removeAll()
    }

    /// Returns an array of the elements in their respective pop order, i.e.
    /// first element in the array is the first element to be popped.
    /// - Returns: array of elements in their respective pop order
    func toArray() -> [T] {
        // TODO: Replace/remove the following line in your implementation.
        return self.underlying_list.reversed()
    }
}
