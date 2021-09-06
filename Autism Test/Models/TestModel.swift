//
//  TestModel.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import Foundation

struct Category: Codable, Equatable, Identifiable {
    let title: String
    let tests: [Test]
    let id: UUID
}

struct Test: Codable, Equatable, Identifiable {
    let title: String
    let subtitle: String
    let scoringKey: String
    let cutOff: Int
    let order: Int
    let source: String
    let questions: [Test.Question]
    let id: UUID
}

extension Test {
    struct Question: Codable, Equatable, Identifiable {
        let title: String
        let type: QuestionType
        let order: Int
        let id: UUID
        let answers: [Test.Answer]
    }
}

extension Test {
    struct Answer: Codable, Equatable, Identifiable {
        let title: String
        let value: Int
        let id: UUID
        let order: Int
    }
}

enum QuestionType: String, Codable {
    case attitude
}
