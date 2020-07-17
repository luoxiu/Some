import XCTest
@testable import Some

final class BinaryHeapTests: XCTestCase {
    
    func testIndex() {
        var heap = BinaryHeap<Int>(>)
        for i in 0..<100 {
            heap.push(i)
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
    
    func testPush() {
        var heap = BinaryHeap<Int>(>)
        
        let nums = Utils.makeRandomInts(100)
        
        for num in nums {
            heap.push(num)
            
            let peek = heap.peek()
            XCTAssertEqual(peek, Array(heap).max())
        }
    }
    
    func testPop() {
        var heap = BinaryHeap<Int>(>)
        
        let nums = Utils.makeRandomInts(100)
        
        for num in nums {
            heap.push(num)
        }
        
        let iterator = AnyIterator {
            heap.pop()
        }
        XCTAssertEqual(Array(iterator), Array(nums.sorted(by: >)))
        XCTAssertEqual(Array(heap), [])
    }
    
    func testIsEmpty() {
        var heap = BinaryHeap<Int>(>)
        XCTAssertTrue(heap.isEmpty)
        
        heap.push(1)
        XCTAssertFalse(heap.isEmpty)
        
        heap.pop()
        XCTAssertTrue(heap.isEmpty)
    }
    
    func testCount() {
        var heap = BinaryHeap<Int>(>)
        XCTAssertEqual(heap.count, 0)
        
        heap.push(1)
        XCTAssertEqual(heap.count, 1)
        
        heap.push(2)
        XCTAssertEqual(heap.count, 2)
        
        for i in 0..<100 {
            heap.push(i)
        }
        XCTAssertEqual(heap.count, 102)
    }
    
    func testRemove() {
        var heap = BinaryHeap<Int>(>)
        
        let nums = Utils.makeRandomInts(100)
        
        for num in nums {
            heap.push(num)
        }
        
        let random = nums.randomElement()!
        
        var copy = nums
        heap.removeAll(where: { $0 == random })
        copy.removeAll(where: { $0 == random })
        XCTAssertEqual(heap.count, copy.count)
        
        heap.removeAll()
        XCTAssertTrue(heap.isEmpty)
    }
    
    func testPopAndPush() {
        var heap = BinaryHeap<Int>(>)
        heap.push(0)
        
        let nums = Utils.makeRandomInts(100)
        
        for num in nums {
            let peak = heap.peek()
            let count = heap.count
            
            let pop = heap.popAndPush(num)
         
            XCTAssertEqual(pop, peak)
            XCTAssertEqual(heap.count, count)
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
}
