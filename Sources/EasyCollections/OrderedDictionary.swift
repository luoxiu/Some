public struct OrderedDictionary<Key, Value> where Key: Hashable {
    
    public typealias Element = (key: Key, value: Value)
    
    private var dict: [Key: Value]
    private var orderedKeys: ContiguousArray<Key>
}

// MARK: - Creating a Dictionary
extension OrderedDictionary {
    public init() {
        dict = [:]
        orderedKeys = []
    }
    
    public init(minimumCapacity: Int) {
        dict = Dictionary(minimumCapacity: minimumCapacity)
        orderedKeys = []
        orderedKeys.reserveCapacity(minimumCapacity)
    }
    
    public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value) {
        self.init(keysAndValues, uniquingKeysWith: { _, _ in preconditionFailure("The sequence must not have duplicate keys.") })
    }
    
    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        if let dict = keysAndValues as? OrderedDictionary<Key, Value> {
            self = dict
            return
        }
        
        self.init(minimumCapacity: keysAndValues.underestimatedCount)
        
        for (k, v) in keysAndValues {
            if let exist = dict[k] {
                dict[k] = try combine(exist, v)
            } else {
                dict[k] = v
                orderedKeys.append(k)
            }
        }
    }
    
    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S : Sequence {
        self.init(minimumCapacity: values.underestimatedCount)
        
        for v in values {
            let k = try keyForValue(v)
            if dict[k] == nil {
                dict[k] = [v]
                orderedKeys.append(k)
            } else {
                dict[k]!.append(v)
            }
        }
    }
}

// MARK: - Inspecting a Dictionary
extension OrderedDictionary {
    public var isEmpty: Bool {
        return dict.isEmpty
    }
    
    public var count: Int {
        return dict.count
    }
    
    public var capacity: Int {
        return dict.capacity
    }
}

// MARK: - Accessing Keys and Values
extension OrderedDictionary {
    
    public subscript(key: Key) -> Value? {
        get {
            return dict[key]
        }
        set {
            dict[key] = newValue
            
            if newValue == nil, let i = orderedKeys.firstIndex(of: key) {
                orderedKeys.remove(at: i)
            } else {
                orderedKeys.append(key)
            }
        }
    }
    
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return dict[key, default: defaultValue()]
        }
        set {
            if dict[key] == nil {
                orderedKeys.append(key)
            }
            dict[key, default: defaultValue()] = newValue
        }
    }
    
    public func index(forKey key: Key) -> Int? {
        return firstIndex(where: { $0.key == key })
    }
    
    public subscript(position: Int) -> Element {
        let k = orderedKeys[position]
        return (k, dict[k]!)
    }
    
    public typealias Keys = LazyMapCollection<OrderedDictionary<Key, Value>, Key>
    
    public var keys: Keys {
        return lazy.map { $0.key }
    }
    
    public typealias Values = LazyMapCollection<OrderedDictionary<Key, Value>, Value>
    
    public var values: Values {
        return lazy.map { $0.value }
    }
}

extension OrderedDictionary {
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        if let v = dict.updateValue(value, forKey: key) {
            return v
        }
        self[key] = value
        return nil
    }
    
    public mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        for (k, v) in other {
            if let exist = dict[k] {
                dict[k] = try combine(exist, v)
            } else {
                self[k] = v
            }
        }
    }
    
    public mutating func merge(_ other: OrderedDictionary<Key, Value>, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try merge(other, uniquingKeysWith: combine)
    }
    
    public func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<Key, Value> where S : Sequence, S.Element == (Key, Value) {
        var d = self
        try d.merge(other, uniquingKeysWith: combine)
        return d
    }
    
    public func merging(_ other: OrderedDictionary<Key, Value>, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> OrderedDictionary<Key, Value> {
        var d = self
        try d.merge(other, uniquingKeysWith: combine)
        return d
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        orderedKeys.reserveCapacity(minimumCapacity)
        dict.reserveCapacity(minimumCapacity)
    }
}

// MARK: - Removing Keys and Values
extension OrderedDictionary {
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> OrderedDictionary<Key, Value> {
        var new = OrderedDictionary<Key, Value>()
        for e in self {
            if try isIncluded(e) {
                new[e.key] = e.value
            }
        }
        return new
    }
    
    public mutating func removeValue(forKey key: Key) -> Value? {
        if let idx = orderedKeys.firstIndex(of: key) {
            orderedKeys.remove(at: idx)
        }
        return dict.removeValue(forKey: key)
    }
    
    public mutating func remove(at index: Int) -> Element {
        let e = self[index]
        let k = orderedKeys[index]
        dict[k] = nil
        return e
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        orderedKeys.removeAll(keepingCapacity: keepCapacity)
        dict.removeAll(keepingCapacity: keepCapacity)
    }
}

// MARK: - RandomAccessCollection
extension OrderedDictionary: RandomAccessCollection  {
    
    public var startIndex: Int {
        return orderedKeys.startIndex
    }
    
    public var endIndex: Int {
        return orderedKeys.endIndex
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
}

// MARK: - ExpressibleByDictionaryLiteral
extension OrderedDictionary: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }
}

// MARK: - Transforming a Dictionary
extension OrderedDictionary {
    
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> OrderedDictionary<Key, T> {
        let s = try orderedKeys.map { k -> (Key, T) in
            let v = dict[k]!
            let t = try transform(v)
            return (k, t)
        }
        return OrderedDictionary<Key, T>(uniqueKeysWithValues: s)
    }
    
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> OrderedDictionary<Key, T> {
        let s = try orderedKeys.compactMap { k -> (Key, T)? in
            if let v = dict[k], let t = try transform(v) {
                return (k, t)
            } else {
                return nil
            }
        }
        return OrderedDictionary<Key, T>(uniqueKeysWithValues: s)
    }
}

extension OrderedDictionary: Equatable where Value: Equatable {
    
    public static func == (lhs: OrderedDictionary, rhs: OrderedDictionary) -> Bool {
        return lhs.orderedKeys == rhs.orderedKeys && lhs.dict == rhs.dict
    }
}

extension OrderedDictionary: Hashable where Value: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(orderedKeys)
        hasher.combine(dict)
    }
}
