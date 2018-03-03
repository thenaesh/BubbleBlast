// Copyright (c) 2018 NUS CS3217. All rights reserved.

/**
 The `PriorityQueue` accepts and maintains the elements in an order specified by
 their priority. For example, a Minimum Priority Queue of integers will serve
 (poll) the smallest integer first.

 Elements with the same priority are allowed, and such elements may be served in
 any order arbitrarily.

 `PriorityQueue` is a generic type with a type parameter `T` that has to be
 `Comparable` so that `T` can be compared.

 - Authors: CS3217
 - Date: 2018
 */
struct PriorityQueue<T: Comparable> {
    private var heap = [T]()
    private var cmp: (T, T) -> Bool
    
    /// Creates either a Min or Max `PriorityQueue`. Defaults to `min = true`.
    /// - Parameter min: Whether to return smallest elements first.
    init(min: Bool = true) {        
        if min {
            cmp = { $0 < $1 }
        } else {
            cmp = { $0 > $1 }
        }
    }

    /// Adds the element.
    mutating func add(_ item: T) {
        heap.append(item)
        
        var idx = heap.count - 1
        repeat {
            idx = parent(index: idx)
            updateHeapProperty(at: idx)
        } while idx != 0
    }

    /// Returns the currently highest priority element.
    /// - Returns: the element if not nil
    func peek() -> T? {
        guard !heap.isEmpty else {
            return nil
        }
        
        return heap[0]
    }

    /// Removes and returns the highest priority element.
    /// - Returns: the element if not nil
    mutating func poll() -> T? {
        guard !heap.isEmpty else {
            return nil
        }
        
        let highestPriorityElement = heap[0]
        let heapLastValue = heap.popLast().unsafelyUnwrapped // heap guaranteed to be nonzero size
        if !heap.isEmpty {
            heap[0] = heapLastValue
            updateHeapProperty(at: 0)
        }
        return highestPriorityElement
    }

    /// The number of elements in the `PriorityQueue`.
    var count: Int {
        return heap.count
    }

    /// Whether the `PriorityQueue` is empty.
    var isEmpty: Bool {
        return heap.isEmpty
    }
    
    
    
    private func parent(index i: Int) -> Int {
        return i / 2
    }
    
    private func leftChild(index i: Int) -> Int {
        return 2 * i
    }
    
    private func rightChild(index i: Int) -> Int {
        return 2 * i + 1
    }
    
    // MAX-HEAPIFY algorithm from CLRS
    // assumes left(i) and right(i) are heaps
    private mutating func updateHeapProperty(at i: Int) {
        let l = leftChild(index: i)
        let r = rightChild(index: i)
        
        var largest = i // TODO: rename this since it's actually the smallest in a min-heap
        if l < heap.count && cmp(heap[l], heap[i]) {
            largest = l
        }
        if r < heap.count && cmp(heap[r], heap[largest]) {
            largest = r
        }
        
        if largest != i {
            let tmp = heap[i]
            heap[i] = heap[largest]
            heap[largest] = tmp
            
            updateHeapProperty(at: largest)
        }
    }
}
