//
//  Models+CoreData.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import Foundation
import CoreData

extension TestMO: ManagedEntity { }
extension CategoryMO: ManagedEntity { }
extension QuestionMO: ManagedEntity { }
extension AnswerMO: ManagedEntity { }
extension ResultMO: ManagedEntity { }

extension Locale {
    static var backendDefault: Locale {
        return Locale(identifier: "en")
    }

    var shortIdentifier: String {
        return String(identifier.prefix(2))
    }
}

extension Test.Answer {

    @discardableResult
    func store(in context: NSManagedObjectContext) -> AnswerMO? {
        guard let answer = AnswerMO.insertNew(in: context) else {
            return nil
        }
        answer.title = title
        answer.value = Int32(value)
        answer.id = id
        answer.order = Int32(order)

        return answer

    }
    
    init?(managedObject: AnswerMO) {
        guard let title = managedObject.title else {
            return nil
        }

        guard let uuid = managedObject.id else {
            return nil
        }
        self.init(title: title, value: Int(managedObject.value), id: uuid, order: Int(managedObject.order))
    }
}

extension Test.Question {

    @discardableResult
    func store(in context: NSManagedObjectContext) -> QuestionMO? {
        guard let question = QuestionMO.insertNew(in: context) else {
            return nil
        }
        question.title = title
        question.order = Int32(order)
        question.id = id
        let answers = answers.compactMap { $0.store(in: context) }
        question.answers = NSSet(array: answers)
        return question

    }

    init?(managedObject: QuestionMO) {
        guard let title = managedObject.title else {
            return nil
        }

        guard let type = managedObject.type else {
            return nil
        }

        guard let questionType = QuestionType(rawValue: type) else {
            return nil
        }

        guard let uuid = managedObject.id else {
            return nil
        }

        let answers = (managedObject.answers ?? NSSet())
            .toArray(of: AnswerMO.self)
            .compactMap { Test.Answer(managedObject: $0) }
            .sorted(by: { $0.order < $1.order})

        self.init(title: title, type: questionType, order: Int(managedObject.order), id: uuid, answers: answers)
    }
}

extension Category {

    @discardableResult
    func store(in context: NSManagedObjectContext) -> CategoryMO? {
        guard let category = CategoryMO.insertNew(in: context) else {
            return nil
        }
        category.title = title
        let tests = tests.compactMap { $0.store(in: context) }
        category.tests = NSSet(array: tests)
        category.id = id
        return category

    }

    init?(managedObject: CategoryMO) {
        guard let title = managedObject.title else {
            return nil
        }
        guard let uuid = managedObject.id else {
            return nil
        }
        let tests = (managedObject.tests ?? NSSet())
            .toArray(of: TestMO.self)
            .compactMap { Test(managedObject: $0) }
            .sorted(by: { $0.order < $1.order })

        self.init(title: title, tests: tests, id: uuid)
    }
}

extension Test {

    @discardableResult
    func store(in context: NSManagedObjectContext) -> TestMO? {
        guard let test = TestMO.insertNew(in: context) else {
            return nil
        }
        test.title = title
        test.subtitle = subtitle
        test.scoringKey = scoringKey
        test.cutOff = Int32(cutOff)
        let questions = questions.compactMap { $0.store(in: context) }
        test.questions =  NSSet(array: questions)
        test.id = id
        return test
    }

    init?(managedObject: TestMO) {
        guard let title = managedObject.title else {
            return nil
        }
        guard let subtitle = managedObject.subtitle else {
            return nil
        }
        guard let scoringKey = managedObject.scoringKey else {
            return nil
        }
        guard let uuid = managedObject.id else {
            return nil
        }
        let questions = (managedObject.questions ?? NSSet())
            .toArray(of: QuestionMO.self)
            .compactMap { Test.Question(managedObject: $0) }
            .sorted(by: { $0.order < $1.order} )

        self.init(title: title, subtitle: subtitle, scoringKey: scoringKey, cutOff: Int(managedObject.cutOff), order: Int(managedObject.order), questions: questions, id: uuid)
    }
}

extension TestResult {

    @discardableResult
    func store(in context: NSManagedObjectContext) -> ResultMO? {
        guard let result = ResultMO.insertNew(in: context) else {
            return nil
        }
        result.timestamp = date
        result.test = test.store(in: context)
        let questions = questions.compactMap { $0.store(in: context) }
        result.questions =  NSSet(array: questions)
        result.id = id
        return result
    }

    init?(managedObject: ResultMO) {
        guard let date = managedObject.timestamp else {
            return nil
        }
        guard let moTest = managedObject.test else {
            return nil
        }
        guard let test = Test(managedObject: moTest) else {
            return nil
        }
        guard let uuid = managedObject.id else {
            return nil
        }

        let questions = (managedObject.questions ?? NSSet())
            .toArray(of: QuestionMO.self)
            .compactMap { Test.Question(managedObject: $0) }
            .sorted(by: { $0.order < $1.order} )

        self.init(date: date, test: test, id: uuid, questions: questions)
    }
}
