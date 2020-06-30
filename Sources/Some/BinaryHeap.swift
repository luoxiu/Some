/// https://en.wikipedia.org/wiki/Binary_heap#Heap_operations
public struct BinaryHeap<Element> {
    public private(set) var storage: ContiguousArray<Element>
    
    /// - Returns: `true` if `a` should be closer to the root than `b`.
    public typealias Comparator = (Element, Element) -> Bool
    
    public var comparator: Comparator
    
    // MARK: - creations
    public init(_ comparator: @escaping Comparator) {
        self.storage = []
        self.comparator = comparator
    }
    
    // MARK: - index calculations
    
    /// - Returns: `nil` if `i` is not a valid index or does not have parent.
    public func parentIndex(of i: Int) -> Int? {
        guard storage.indices.contains(i) else { return nil }
        if i == 0 { return nil }
        return (i - 1) / 2
    }
    
    /// - Returns: `nil` if `i` is not a valid index or does not have left child.
    public func leftChildIndex(of i: Int) -> Int? {
        guard storage.indices.contains(i) else { return nil }
        let leftChild = 2 * i  + 1
        return storage.indices.contains(leftChild) ? leftChild : nil
    }
    
    /// - Returns: `nil` if `i` is not a valid index or does not have right child.
    public func rightChildIndex(of i: Int) -> Int? {
        guard storage.indices.contains(i) else { return nil }
        let rightChild = 2 * i  + 2
        return storage.indices.contains(rightChild) ? rightChild : nil
    }

    // MARK: - operations
    @discardableResult
    public mutating func push(_ element: Element) -> Int {
        storage.append(element)
        return heapifyUp(storage.count - 1)
    }
    
    @discardableResult
    public mutating func remove(at i: Int) -> Element {
        precondition(storage.indices.contains(i))
        
        if i == storage.endIndex - 1 {
            return storage.removeLast()
        }
        
        let element = storage[i]
        storage.swapAt(i, storage.count - 1)
        storage.removeLast()
        
        heapifyDown(i)
        
        return element
    }
    
    @discardableResult
    public mutating func pop() -> Element? {
        if storage.isEmpty { return nil }
        return remove(at: 0)
    }
    
    public func peek() -> Element? {
        storage.first
    }
    
    /// pop root and push a new element.
    /// More efficient than pop followed by push, since only need to balance once, not twice, and appropriate for fixed-size heaps.
    public mutating func popAndPush(_ element: Element) -> Element? {
        if storage.isEmpty {
            storage.append(element)
            return nil
        }
        
        let root = storage[0]
        storage[0] = element
        heapifyDown(0)
        
        return root
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        storage.removeAll(keepingCapacity: keepingCapacity)
    }
    
    @discardableResult
    private mutating func heapifyUp(_ i: Int) -> Int {
        var index = i
        let element = storage[index]
        
        while let parentIndex = self.parentIndex(of: index) {
            if comparator(storage[parentIndex], element) {
                break
            }
            storage.swapAt(parentIndex, index)
            
            index = parentIndex
        }
        
        return index
    }
    
    @discardableResult
    private mutating func heapifyDown(_ i: Int) -> Int {
        var index = i
        
        if let left = leftChildIndex(of: i), comparator(storage[left], storage[index]) {
            index = left
        }
        if let right = rightChildIndex(of: i), comparator(storage[right], storage[index]) {
            index = right
        }
        
        if index != i {
            storage.swapAt(index, i)
            return heapifyDown(index)
        }
        
        return index
    }
    
    public static func heapify<S>(_ s: S, comparator: @escaping Comparator) -> BinaryHeap<S.Element> where S: Sequence, S.Element == Element {
        var heap = BinaryHeap<Element>(comparator)
        heap.storage = ContiguousArray(s)

        guard var index = heap.parentIndex(of: heap.storage.count - 1) else {
            return heap
        }
        
        while index >= 0 {
            heap.heapifyDown(index)
            index -= 1
        }
        
        return heap
    }
    
    // MARK: - properties
    public var count: Int {
        storage.count
    }
    
    public var isEmpty: Bool {
        storage.isEmpty
    }
}

extension BinaryHeap: Sequence {

    public func makeIterator() -> AnyIterator<Element> {
        var heap = self
        return AnyIterator {
            heap.pop()
        }
    }
}
