import XCTest

import SomeTests

var tests = [XCTestCaseEntry]()
tests += SomeTests.__allTests()

XCTMain(tests)
