/// https://en.wikipedia.org/wiki/Circular_buffer
public struct CircularBuffer<Element>: BidirectionalCollection {
    
    public private(set) var storage: ContiguousArray<Element?>
    private var headStorageIndex = 0
    private var tailStorageIndex = 0
    
    public init(initialCapacity: Int = 16) {
        precondition(initialCapacity >= 0)
        let capacity = Self.nextPowerOf2(UInt(initialCapacity))
        let count = capacity > UInt(Int.max) ? Int.max : Int(capacity)
        self.storage = ContiguousArray(repeating: nil, count: count)
    }
    
    // MARK: - index calculations
    private func advanceStorageIndex(_ i: Int, by n: Int) -> Int {
        return (i &+ n) & (storage.count - 1)
    }
    
    private mutating func advanceHeadStorageIndex(by n: Int) {
        headStorageIndex = advanceStorageIndex(headStorageIndex, by: n)
    }
    
    private mutating func advanceTailStorageIndex(by n: Int) {
        tailStorageIndex = advanceStorageIndex(tailStorageIndex, by: n)
    }

    // MARK: - operations
    public mutating func append(_ element: Element) {
        storage[tailStorageIndex] = element
        advanceTailStorageIndex(by: 1)
        
        if headStorageIndex == tailStorageIndex {
            doubleCapacity()
        }
    }
    
    public mutating func prepend(_ element: Element) {
        let index = advanceStorageIndex(headStorageIndex, by: -1)
        storage[index] = element
        advanceHeadStorageIndex(by: -1)
        
        if headStorageIndex == tailStorageIndex {
            doubleCapacity()
        }
    }
    
    private mutating func doubleCapacity() {
        let oldCount = self.storage.count
        let newCapacity = Swift.max(16, oldCount << 1)

        var newStorage: ContiguousArray<Element?> = []
        newStorage.reserveCapacity(newCapacity)
        newStorage.append(contentsOf: storage[headStorageIndex..<oldCount])
        if headStorageIndex > 0 {
            newStorage.append(contentsOf: storage[0..<headStorageIndex])
        }
        
        let rest = newCapacity - newStorage.count
        newStorage.append(contentsOf: repeatElement(nil, count: rest))
        
        self.headStorageIndex = 0
        self.tailStorageIndex = oldCount
        
        self.storage = newStorage
    }
    
    @discardableResult
    public mutating func popFirst() -> Element? {
        if isEmpty {
            return nil
        }
        
        let e = storage[headStorageIndex]
        storage[headStorageIndex] = nil
        advanceHeadStorageIndex(by: 1)
        return e
    }
    
    @discardableResult
    public mutating func popLast() -> Element? {
        if isEmpty {
            return nil
        }
        
        advanceTailStorageIndex(by: -1)
        let e = storage[tailStorageIndex]
        storage[tailStorageIndex] = nil
        return e
    }
    
    @discardableResult
    public mutating func remove(at i: Index) -> Element {
        precondition(indices.contains(i))
        
        var index = storageIndex(of: i)
        let element = storage[index]!
        
        if index == headStorageIndex {
            advanceHeadStorageIndex(by: 1)
            storage[index] = nil
            return element
        }
        
        if index == self.index(before: endIndex).distanceToHead {
            advanceTailStorageIndex(by: -1)
            storage[index] = nil
            return element
        }
        
        storage[index] = nil
        var next = advanceStorageIndex(index, by: 1)
        while next != tailStorageIndex {
            storage.swapAt(next, index)
            index = next
            next = advanceStorageIndex(index, by: 1)
        }
        
        advanceTailStorageIndex(by: -1)
        
        return element
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        if keepingCapacity {
            while popFirst() != nil {
                // noop
            }
        } else {
            self.storage.removeAll(keepingCapacity: false)
            self.storage.append(nil)
        }
        self.headStorageIndex = 0
        self.tailStorageIndex = 0
    }
    
    // MARK: - properties
    public var isEmpty: Bool {
        return headStorageIndex == tailStorageIndex
    }
    
    public var count: Int {
        let d = tailStorageIndex - headStorageIndex
        return d >= 0 ? d : (storage.count + d)
    }
    
    // MARK: - Collection
    public struct Index: Comparable {
        
        fileprivate let distanceToHead: Int
        
        fileprivate init(distanceToHead: Int) {
            self.distanceToHead = distanceToHead
        }
        
        public static func < (a: Index, b: Index) -> Bool {
            a.distanceToHead < b.distanceToHead
        }
    }
    
    public var startIndex: Index {
        Index(distanceToHead: 0)
    }
    
    public var endIndex: Index {
        Index(distanceToHead: count)
    }
    
    public func index(after i: Index) -> Index {
        Index(distanceToHead: i.distanceToHead + 1)
    }
    
    public func index(before i: Index) -> Index {
        Index(distanceToHead: i.distanceToHead - 1)
    }
    
    public func index(_ i: Index, offsetBy n: Int) -> Index {
        Index(distanceToHead: i.distanceToHead + n)
    }
    
    private func storageIndex(of i: Index) -> Int {
        advanceStorageIndex(headStorageIndex, by: i.distanceToHead)
    }
    
    public subscript(i: Index) -> Element {
        storage[storageIndex(of: i)]!
    }
}

extension CircularBuffer {

    static func nextPowerOf2(_ n: UInt) -> UInt {
        if n == 0 { return 1 }
        if n & (n - 1)  == 0 { return n }
        return 1 << (n.bitWidth - (n - 1).leadingZeroBitCount)
    }
}
