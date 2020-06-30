import XCTest
@testable import Some

final class CircularBufferTests: XCTestCase {
    
    func testAppendAndPopLast() {
        var nums = Utils.makeRandomInts(100)
        
        var buffer = CircularBuffer<Int>()
        
        nums.forEach {
            buffer.append($0)
        }
        
        while let last = buffer.popLast() {
            XCTAssertEqual(last, nums.removeLast())
        }
    }
    
    func testPrependAndPopFirst() {
        var nums = Utils.makeRandomInts(100)
        
        var buffer = CircularBuffer<Int>()
        
        nums.forEach {
            buffer.prepend($0)
        }
        
        while let last = buffer.popFirst() {
            XCTAssertEqual(last, nums.removeLast())
        }
    }
    
    func testRemoveAt() {
        let nums = Array(0..<100)
        
        var buffer = CircularBuffer<Int>()
        
        nums.forEach {
            buffer.append($0)
        }
        
        let index = buffer.index(buffer.startIndex, offsetBy: 10)
        XCTAssertEqual(buffer.remove(at: index), 10)
    }
    
    func testCount() {
        let nums = Array(0..<100)
        
        var buffer = CircularBuffer<Int>()
        
        nums.forEach {
            buffer.append($0)
            XCTAssertEqual(buffer.count, $0 + 1)
        }
        
        buffer.remove(at: buffer.indices.randomElement()!)
        
        XCTAssertEqual(buffer.count, 99)
    }
    
    func testIsEmpty() {
        var buffer = CircularBuffer<Int>()
        
        XCTAssertEqual(buffer.isEmpty, true)
        
        buffer.append(1)
        XCTAssertEqual(buffer.isEmpty, false)
        
        buffer.popLast()
        XCTAssertEqual(buffer.isEmpty, true)
    }
    
    func testIndex() {
        let nums = Utils.makeRandomInts(100)
        
        var buffer = CircularBuffer<Int>()
        
        nums.forEach {
            buffer.append($0)
        }
        
        var index = 0
        var bufferIndex = buffer.startIndex
        
        while index < 100 {
            XCTAssertEqual(buffer[bufferIndex], nums[index])
            
            index += 1
            bufferIndex = buffer.index(after: bufferIndex)
        }
        
        index -= 1
        bufferIndex = buffer.index(before: bufferIndex)
        
        while index >= 0 {
            XCTAssertEqual(buffer[bufferIndex], nums[index])
            
            index -= 1
            bufferIndex = buffer.index(before: bufferIndex)
        }
    }
    
    static var allTests = [
        ("testAppendAndPopLast", testAppendAndPopLast),
        ("testPrependAndPopFirst", testPrependAndPopFirst),
        ("testRemoveAt", testRemoveAt),
        ("testCount", testCount),
        ("testIsEmpty", testIsEmpty),
        ("testIndex", testIndex),
    ]
}
