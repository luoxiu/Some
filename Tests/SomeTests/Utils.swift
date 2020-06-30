enum Utils {
    static func makeRandomInt() -> Int {
        Int.random(in: 0..<Int.max)
    }
    
    static func makeRandoms<T>(_ random: @autoclosure () -> T, _ count: Int) -> [T] {
        var randoms: [T] = []
        for _ in 0..<count {
            randoms.append(random())
        }
        return randoms
    }
    
    static func makeRandomInts(_ count: Int) -> [Int] {
        makeRandoms(Int.random(in: Int.min...Int.max), count)
    }
}
