import Foundation

class ScoreCard: NSObject {

    var playerName: String = ""
    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var questionsAsked: Int32 = 0
    var questionsAttempted: Int32 = 0
    var rightAnswers: Int32 = 0
    var wrongAnswers: Int32 = 0
    var percentScore: Float = 0
    var secondsTaken: Int32 = 0
    private(set) var scoreRank: Int32 = -1
    private(set) var scoreDateTime: Date?
    private(set) var scoreCard: [String: Any]?
    private(set) var isTopScore: Bool = false

    private var scoresFilePath: String {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = String(format: kFileVarScores, activity, activityType, activityLevel)
        return docs + "/" + fileName
    }

    @discardableResult
    func newScoreCard() -> [String: Any] {
        var card: [String: Any] = [
            kPlayerName: playerName,
            kActivity: NSNumber(value: activity),
            kActivityType: NSNumber(value: activityType),
            kActivityLevel: NSNumber(value: activityLevel),
            kQuestionsAsked: NSNumber(value: questionsAsked),
            kQuestionsAttempted: NSNumber(value: questionsAttempted),
            kRightAnswers: NSNumber(value: rightAnswers),
            kWrongAnswers: NSNumber(value: wrongAnswers),
            kPercentScore: NSNumber(value: percentScore),
            kSecondsTaken: NSNumber(value: secondsTaken),
            kScoreDateTime: Date()
        ]

        isTopScore = false
        scoreRank = -1

        if rightAnswers > 0 {
            let existing = (NSArray(contentsOfFile: scoresFilePath) as? [[String: Any]]) ?? []

            if existing.count <= KidsTimeFunAppState.sharedState().sizeOfTopScoreList {
                isTopScore = true
                scoreRank = Int32(existing.count) + 1
            }

            for (i, entry) in existing.enumerated() {
                let thisSortKey = sortKey(for: self)
                let arrSortKey = sortKey(fromDict: entry)
                if thisSortKey >= arrSortKey {
                    scoreRank = Int32(i) + 1
                    isTopScore = true
                    break
                }
            }
        }

        card[kScoreRank] = NSNumber(value: scoreRank)
        scoreCard = card
        return card
    }

    func writeScoreCard() -> Bool {
        guard isTopScore, let card = scoreCard else { return false }
        let existing = (NSArray(contentsOfFile: scoresFilePath) as? [[String: Any]]) ?? []
        var updated: [[String: Any]] = []
        for i in 0..<(Int(scoreRank) - 1) where i < existing.count {
            updated.append(existing[i])
        }
        updated.append(card)
        let maxSize = min(existing.count + 1, Int(KidsTimeFunAppState.sharedState().sizeOfTopScoreList))
        for i in Int(scoreRank)..<maxSize where (i - 1) < existing.count {
            updated.append(existing[i - 1])
        }
        guard let data = try? PropertyListSerialization.data(fromPropertyList: updated, format: .xml, options: 0) else { return false }
        return (try? data.write(to: URL(fileURLWithPath: scoresFilePath))) != nil
    }

    private func sortKey(for card: ScoreCard) -> Int64 {
        switch card.activityType {
        case kActTypeNumbered:
            let pct = Int(card.percentScore * 10000)
            let q = Int(card.questionsAsked)
            let s = 900 - Int(card.secondsTaken)
            return Int64("\(pct)\(q)\(s)") ?? 0
        case kActTypeTimed:
            let s = 900 - Int(card.secondsTaken)
            let q = Int(card.questionsAsked)
            let r = Int(card.rightAnswers)
            return Int64("\(s)\(q)\(r)") ?? 0
        default:
            return 0
        }
    }

    private func sortKey(fromDict d: [String: Any]) -> Int64 {
        switch activityType {
        case kActTypeNumbered:
            let pct = Int(((d[kPercentScore] as? NSNumber)?.floatValue ?? 0) * 10000)
            let q = (d[kQuestionsAsked] as? NSNumber)?.intValue ?? 0
            let s = 900 - ((d[kSecondsTaken] as? NSNumber)?.intValue ?? 0)
            return Int64("\(pct)\(q)\(s)") ?? 0
        case kActTypeTimed:
            let s = 900 - ((d[kSecondsTaken] as? NSNumber)?.intValue ?? 0)
            let q = (d[kQuestionsAsked] as? NSNumber)?.intValue ?? 0
            let r = (d[kRightAnswers] as? NSNumber)?.intValue ?? 0
            return Int64("\(s)\(q)\(r)") ?? 0
        default:
            return 0
        }
    }
}
