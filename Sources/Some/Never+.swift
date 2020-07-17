extension Never {
    
    static func unimplemented(file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("unimplemented", file: file, line: line)
    }
}
