//
//  StatementPositionRule.swift
//  SwiftLint
//
//  Created by Alex Culeva on 10/22/15.
//  Copyright © 2015 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

public struct StatementPositionRule: CorrectableRule {

    public init() {}

    public static let description = RuleDescription(
        identifier: "statement_position",
        name: "Statement Position",
        description: "Else and catch should be on the same line, one space after the previous " +
                     "declaration.",
        nonTriggeringExamples: [
            "} else if {",
            "} else {",
            "} catch {",
            "\"}else{\"",
            "struct A { let catchphrase: Int }\nlet a = A(\n catchphrase: 0\n)",
            "struct A { let `catch`: Int }\nlet a = A(\n `catch`: 0\n)"
        ],
        triggeringExamples: [
            "↓}else if {",
            "}↓  else {",
            "}↓\ncatch {",
            "}\n\t↓  catch {"
        ],
        corrections: [
            "}\n else {\n": "} else {\n",
            "}\n   else if {\n": "} else if {\n",
            "}\n catch {\n": "} catch {\n"
        ]
    )

    public func validateFile(file: File) -> [StyleViolation] {
        let pattern = "(?:\\}|[\\s] |[\\n\\t\\r])\\b(?:else|catch)\\b"

        return violationRangesInFile(file, withPattern: pattern).flatMap { range in
            return StyleViolation(ruleDescription: self.dynamicType.description,
                location: Location(file: file, characterOffset: range.location))
        }
    }

    public func correctFile(file: File) -> [Correction] {
        let pattern = "\\}\\s+((?:else|catch))\\b"

        let matches = violationRangesInFile(file, withPattern: pattern)
        guard !matches.isEmpty else { return [] }

        let regularExpression = regex(pattern)
        let description = self.dynamicType.description
        var corrections = [Correction]()
        var contents = file.contents
        for range in matches.reverse() {
            contents = regularExpression.stringByReplacingMatchesInString(contents,
                options: [], range: range, withTemplate: "} $1")
            let location = Location(file: file, characterOffset: range.location)
            corrections.append(Correction(ruleDescription: description, location: location))
        }
        file.write(contents)
        return corrections
    }

    // MARK: - Private Methods

    private func violationRangesInFile(file: File, withPattern pattern: String) -> [NSRange] {
        return file.matchPattern(pattern).filter { range, syntaxKinds in
            return syntaxKinds.startsWith([.Keyword])
        }.flatMap { $0.0 }
    }
}
