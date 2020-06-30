import XCTest

import SomeTests

var tests = [XCTestCaseEntry]()
tests += SomeTests.allTests()
XCTMain(tests)
