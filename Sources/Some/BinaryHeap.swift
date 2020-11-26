/// https://en.wikipedia.org/wiki/Binary_heap#Heap_operations
public struct BinaryHeap<Element> {
    private var array: ContiguousArray<Element>
    
    /// - Returns: `true` if `a` should be closer to the root than `b`.
    public typealias Comparator = (Element, Element) -> Bool
    
    public var comparator: Comparator
    
    // MARK: - creations
    public init(_ comparator: @escaping Comparator) {
        self.array = []
        self.comparator = comparator
    }
    
    // MARK: - index calculations
    
    /// - Returns: `nil` if `i` is not a valid index or has no parent.
    public func parentIndex(of i: Int) -> Int? {
        guard array.indices.contains(i) else { return nil }
        if i == 0 { return nil }
        return (i - 1) / 2
    }
    
    /// - Returns: `nil` if `i` is not a valid index or has no left child.
    public func leftChildIndex(of i: Int) -> Int? {
        let indices = array.indices
        
        guard indices.contains(i) else { return nil }
        let leftChild = 2 * i  + 1
        return indices.contains(leftChild) ? leftChild : nil
    }
    
    /// - Returns: `nil` if `i` is not a valid index or has no right child.
    public func rightChildIndex(of i: Int) -> Int? {
        let indices = array.indices
        
        guard indices.contains(i) else { return nil }
        let rightChild = 2 * i  + 2
        return indices.contains(rightChild) ? rightChild : nil
    }

    // MARK: - operations
    @discardableResult
    public mutating func push(_ element: Element) -> Int {
        array.append(element)
        return heapifyUp(array.count - 1)
    }
    
    @discardableResult
    public mutating func pop() -> Element? {
        if array.isEmpty { return nil }
        return remove(at: 0)
    }
    
    public func peek() -> Element? {
        array.first
    }
    
    /// pop root and push a new element.
    /// More efficient than pop followed by push, since only need to balance once, not twice, and appropriate for fixed-size heaps.
    public mutating func popAndPush(_ element: Element) -> Element? {
        if array.isEmpty {
            array.append(element)
            return nil
        }
        
        let root = array[0]
        array[0] = element
        heapifyDown(0)
        
        return root
    }
    
    @discardableResult
    private mutating func remove(at i: Int) -> Element {
        precondition(array.indices.contains(i))
        
        if i == array.endIndex - 1 {
            return array.removeLast()
        }
        
        let element = array[i]
        array.swapAt(i, array.count - 1)
        array.removeLast()
        
        heapifyDown(i)
        
        return element
    }
    
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        var copy = self.array
        try copy.removeAll(where: shouldBeRemoved)
        self = BinaryHeap.heapify(copy, comparator: comparator)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        array.removeAll(keepingCapacity: keepingCapacity)
    }
    
    @discardableResult
    private mutating func heapifyUp(_ i: Int) -> Int {
        var index = i
        let element = array[index]
        
        while let parentIndex = self.parentIndex(of: index) {
            if comparator(array[parentIndex], element) {
                break
            }
            
            array.swapAt(parentIndex, index)
            
            index = parentIndex
        }
        
        return index
    }
    
    @discardableResult
    private mutating func heapifyDown(_ i: Int) -> Int {
        var index = i
        
        if let left = leftChildIndex(of: i), comparator(array[left], array[index]) {
            index = left
        }
        if let right = rightChildIndex(of: i), comparator(array[right], array[index]) {
            index = right
        }
        
        if index != i {
            array.swapAt(index, i)
            return heapifyDown(index)
        }
        
        return index
    }
    
    public static func heapify<S>(_ s: S, comparator: @escaping Comparator) -> BinaryHeap<S.Element> where S: Sequence, S.Element == Element {
        var heap = BinaryHeap<Element>(comparator)
        heap.array = ContiguousArray(s)

        guard var index = heap.parentIndex(of: heap.array.count - 1) else {
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
        array.count
    }
    
    public var isEmpty: Bool {
        array.isEmpty
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
