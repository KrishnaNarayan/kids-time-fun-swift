import Foundation

class RandomInteger: NSObject {

    var rangeLow: Int
    var rangeHigh: Int

    var randomInteger: Int {
        return nextRandomInteger()
    }

    init(range low: Int, to high: Int) {
        rangeLow = low
        rangeHigh = high
    }

    func nextRandomInteger() -> Int {
        return Int.random(in: rangeLow...rangeHigh)
    }

    func nextRandomInteger(inRange low: Int, to high: Int) -> Int {
        rangeLow = low
        rangeHigh = high
        return nextRandomInteger()
    }
}
