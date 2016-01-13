//
//  CollectionShorthandSyntaxRule.swift
//  SwiftLint
//
//  Created by Brandon Kobilansky on 1/12/16.
//  Copyright (c) 2016 Realm. All rights reserved.
//

import SourceKittenFramework

public struct CollectionShorthandSyntaxRule: Rule {
    public init() {}

    public static let description = RuleDescription(
        identifier: "collection_shorthand_syntax",
        name: "Collection Shorthand Syntax",
        description: "Prefer shorthand syntax for collections instead of the Generic syntax",
        nonTriggeringExamples: [
            "var ints: [Int] = [1, 2, 3]",
            "let ints: [Int] = [1, 2, 3]",
            "func getInts() -> [Int] { return [1] }",

            "var ints: [String: Int] = [\"a\": 1, \"b\": 2, \"c\": 3]",
            "let ints: [Int:Int] = [1: 1, 2:2, 3:3]",
            "let ints:[Int:Int] = [1: 1, 2:2, 3:3]",
            "func getInts() ->[String: String] { return [1] }",

        ],
        triggeringExamples: [
            "var ints: Array<Int> = [1, 2, 3]",
            "let ints: Array<Int> = [1, 2, 3]",
            "let ints:Array<Int> = [1, 2, 3]",
            "func getInts() -> Array<Int> { return [1] }",

            "var ints: Dictionary<String, Int> = [\"a\": 1, \"b\": 2, \"c\": 3]",
            "let ints: Dictionary<Int,Int> = [1: 1, 2:2, 3:3]",
            "let ints:Dictionary<Int,Int> = [1: 1, 2:2, 3:3]",
            "func getInts() -> Dictionary<String, String> { return [1] }",
            "func getInts()->Dictionary<String, String> { return [1] }",
        ]
    )

    public func validateFile(file: File) -> [StyleViolation] {
        return pairs.reduce([StyleViolation]()) { (results, pair) -> [StyleViolation] in
            results + file.matchPattern(pair.pattern).flatMap { (range, kind) -> StyleViolation? in
                if kind == [.String] {
                    return nil
                } else {
                    return StyleViolation(
                        ruleDescription: self.dynamicType.description,
                        location: Location(file: file, characterOffset: range.location)
                    )
                }
            }
        }
    }

    private var pairs: [(pattern: String, correction: String)] {
        let prefix = "(:|\\s+|>)"
        let arrayPair = (prefix + "Array<\\s*(\\w*)\\s*>", "$1[$2]")
        let dictionaryPair = (prefix + "Dictionary<\\s*(\\w+)\\s*,\\s*(\\w+)\\s*>", "$1[$2: $3]")
        return [arrayPair, dictionaryPair]
    }
}
