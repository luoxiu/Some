import XCTest
@testable import EasyCollections

final class InfiniteRepeatedTests: XCTestCase {
    
    func testInfinite() {
        let s = InfiniteRepeated(1)
        
        var elements: [Int] = []
        for e in s {
            elements.append(e)
            if elements.count == 100 {
                break
            }
        }
        
        XCTAssertEqual(elements, Array(repeatElement(1, count: 100)))
    }
    
    func testSubscript() {
        let s = InfiniteRepeated(1)
        
        XCTAssertEqual(s[0], s[1])
        XCTAssertEqual(s[0], s[2])
        XCTAssertEqual(s[0], s[3])
    
        XCTAssertEqual(Array(s[0..<100]), Array(repeatElement(1, count: 100)))
    }
}
