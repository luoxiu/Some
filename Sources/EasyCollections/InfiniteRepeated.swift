public struct InfiniteRepeated<Element> {
    
    private let e: Element
    
    public init(_ e: Element) {
        self.e = e
    }
}

extension InfiniteRepeated: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        AnyIterator {
            self.e
        }
    }
}

extension InfiniteRepeated {
    
    public subscript(position: Int) -> Element {
        return e
    }
    
    subscript(bounds: Range<Int>) -> Array<Element> {
        return Array(repeating: e, count: bounds.count)
    }
}
