extension Never {
    
    static var unimplemented: Never {
        return fatalError("unimplemented")
    }
}
