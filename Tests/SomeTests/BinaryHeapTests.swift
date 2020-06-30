import XCTest
@testable import Some

final class BinaryHeapTests: XCTestCase {
    
    func testIndex() {
        let nums = Utils.makeRandomInts(100)
        var heap = BinaryHeap<Int>(>)
        nums.forEach {
            heap.push($0)
        }
        
        XCTAssertEqual(heap.parentIndex(of: -1), nil)
        XCTAssertEqual(heap.parentIndex(of: 100), nil)
        XCTAssertEqual(heap.parentIndex(of: 0), nil)
        XCTAssertEqual(heap.parentIndex(of: 2), 0)
        
        XCTAssertEqual(heap.leftChildIndex(of: -1), nil)
        XCTAssertEqual(heap.rightChildIndex(of: -1), nil)
        XCTAssertEqual(heap.leftChildIndex(of: 100), nil)
        XCTAssertEqual(heap.rightChildIndex(of: 100), nil)
        
        XCTAssertEqual(heap.leftChildIndex(of: 99), nil)
        XCTAssertEqual(heap.leftChildIndex(of: 0), 1)
        XCTAssertEqual(heap.rightChildIndex(of: 99), nil)
        XCTAssertEqual(heap.rightChildIndex(of: 0), 2)
    }
    
    func testInsert() {
        let nums = Utils.makeRandomInts(100)

        var heap = BinaryHeap<Int>(>)
        for num in nums {
            heap.push(num)
            XCTAssertEqual(heap.peek(), heap.storage.max())
        }
    }
    
    func testPop() {
        let nums = Utils.makeRandomInts(100)
        var heap = BinaryHeap<Int>(>)
        nums.forEach {
            heap.push($0)
        }

        for (a, b) in zip(heap, nums.sorted(by: >)) {
            XCTAssertEqual(a, b)
        }
    }
    
    func testPeak() {
        let nums = Utils.makeRandomInts(100)
        var heap = BinaryHeap<Int>(>)
        nums.forEach {
            heap.push($0)
        }
        for _ in nums {
            XCTAssertEqual(heap.peek(), nums.max())
        }
    }
    
    func testSequence() {
        let nums = Utils.makeRandomInts(100)
        var heap = BinaryHeap<Int>(>)
        
        nums.forEach {
            heap.push($0)
        }
        
        XCTAssertEqual(Array(heap), nums.sorted(by: >))
    }
    
    func testHeapify() {
        let nums = Utils.makeRandomInts(100)
        
        var heap = BinaryHeap<Int>(>)
        nums.forEach {
            heap.push($0)
        }
        
        let heapified = BinaryHeap.heapify(nums, comparator: >)
        
        for (a, b) in zip(heap, heapified) {
            XCTAssertEqual(a, b)
        }
    }
    
    static var allTests = [
        ("testIndex", testIndex),
        ("testInsert", testInsert),
        ("testPop", testPop),
        ("testPeak", testPeak),
        ("testSequence", testSequence),
        ("testHeapify", testHeapify),
    ]
}
