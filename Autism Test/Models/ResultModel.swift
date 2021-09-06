//
//  ResultModel.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import Foundation

struct TestResult: Codable, Equatable {

    let date: Date
    let test: Test
    let id: UUID
    var questions: [Test.Question]
}
