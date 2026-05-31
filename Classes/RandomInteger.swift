// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

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
