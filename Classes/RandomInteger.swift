// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
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
