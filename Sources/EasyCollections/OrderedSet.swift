public struct OrderedSet<Element> where Element: Hashable {

    private var set: Set<Element>
    private var orderedElements: ContiguousArray<Element>
}
 
// MARK: - Creating a Set
extension OrderedSet {
    
    public init() {
        set = []
        orderedElements = []
    }

    public init(minimumCapacity: Int) {
        set = Set(minimumCapacity: minimumCapacity)
        orderedElements = []
        orderedElements.reserveCapacity(minimumCapacity)
    }
    
    public init<S>(_ sequence: S) where S : Sequence, Self.Element == S.Element {
        if let s = sequence as? OrderedSet<Element> {
            self = s
        } else {
            self.init(minimumCapacity: sequence.underestimatedCount)
            for i in sequence {
                _ = insert(i)
            }
        }
    }
}

// MARK: - Inspecting a Set
extension OrderedSet {

    public var isEmpty: Bool {
        return count == 0
    }
    
    
    public var count: Int {
        return orderedElements.count
    }
    
    public var capacity: Int {
        return orderedElements.capacity
    }
}

// MARK: - Testing for Membership
extension OrderedSet: Sequence {

    public func contains(_ element: Element) -> Bool {
        return set.contains(element)
    }
}

// MARK: - Adding Elements
extension OrderedSet {
    
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let result = set.insert(newMember)
        if result.inserted {
            orderedElements.append(newMember)
        }
        return result
    }

    public mutating func update(with newMember: Element) -> Element? {
        if let result = set.update(with: newMember) {
            orderedElements.append(newMember)
            return result
        }
        return nil
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        orderedElements.reserveCapacity(minimumCapacity)
        set.reserveCapacity(minimumCapacity)
    }
}

// MARK: - Removing Elements
extension OrderedSet {

    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> OrderedSet<Element> {
        var new = OrderedSet<Element>()
        for e in self {
            if try isIncluded(e) {
                _ = new.insert(e)
            }
        }
        return new
    }
    
    public mutating func remove(_ member: Element) -> Element? {
        guard
            let new = set.remove(member),
            let idx = orderedElements.firstIndex(of: new)
        else {
            return nil
        }

        orderedElements.remove(at: idx)
        
        return new
    }
    
    public mutating func removeFirst() -> Element {
        return remove(at: startIndex)
    }
    
    public mutating func remove(at position: Int) -> Element {
        set.remove(self[position])
        return orderedElements.remove(at: position)
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        orderedElements.removeAll(keepingCapacity: keepCapacity)
        set.removeAll(keepingCapacity: keepCapacity)
    }
}

extension OrderedSet: RandomAccessCollection {

    public var startIndex: Int {
        return orderedElements.startIndex
    }

    public var endIndex: Int {
        return orderedElements.endIndex
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public func index(before i: Int) -> Int {
        return i - 1
    }

    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        return i + distance
    }

    public func distance(from start: Int, to end: Int) -> Int {
        return end - start
    }

    public subscript(position: Int) -> Element {
        return orderedElements[position]
    }

}

// MARK: - Combining Sets
extension OrderedSet: SetAlgebra {

    public func union(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
        var new = self
        new.formUnion(other)
        return new
    }
    
    public mutating func formUnion(_ other: OrderedSet<Element>) {
        for e in other.orderedElements where !set.insert(e).inserted {
            orderedElements.append(e)
        }
    }

    public func intersection(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
        var new = OrderedSet<Element>()
        for e in other.orderedElements where set.contains(e) {
            new.orderedElements.append(e)
            new.set.insert(e)
        }
        return new
    }
    
    public mutating func formIntersection(_ other: OrderedSet<Element>) {
        let result = intersection(other)
        if result.count != count {
            self = result
        }
    }


    public func symmetricDifference(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
        var new = self
        new.formSymmetricDifference(other)
        return new
    }

    public mutating func formSymmetricDifference(_ other: OrderedSet<Element>) {
        for e in other {
            if contains(e) {
                _ = remove(e)
            } else {
                _ = insert(e)
            }
        }
    }

}

// MARK: - ExpressibleByArrayLiteral
extension OrderedSet: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Element...) {
        if elements.isEmpty {
            self.init()
            return
        }

        self.init(minimumCapacity: elements.count)
        for e in elements where set.insert(e).inserted {
            orderedElements.append(e)
        }
    }
}

extension OrderedSet: Equatable {

    public static func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool {
        return lhs.orderedElements == rhs.orderedElements && lhs.set == rhs.set
    }
}

extension OrderedSet: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(orderedElements)
        hasher.combine(set)
    }
}
