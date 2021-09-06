//
//  TestSelectorInteractor.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import Combine
import Foundation
import SwiftUI

protocol TestSelectorInteractor {
    func load(tests: LoadableSubject<LazyList<Test>>)
    func select(answer: Test.Answer, in questions: [Test.Question])
    func currentQuestion(for testResult: TestResult) -> Test.Question?
}


struct RealTestSelectorInteractor: TestSelectorInteractor {

    let appState: Store<AppState>
    let dbRepository: TestsDBRepository
    let jsonRepository: JSONRepository


    init(dbRepository: TestsDBRepository, jsonRepository: JSONRepository, appState: Store<AppState>) {
        self.dbRepository = dbRepository
        self.appState = appState
        self.jsonRepository = jsonRepository
    }

    func load(tests: LoadableSubject<LazyList<Test>>) {
        let cancelBag = CancelBag()
        tests.wrappedValue.setIsLoading(cancelBag: cancelBag)

        Just<Void>
            .withErrorType(Error.self)
            .flatMap { [dbRepository] _ -> AnyPublisher<Bool, Error> in
                dbRepository.hasPrefilledTests()
            }
            .flatMap { hasPreffiled -> AnyPublisher<Void, Error> in
                if hasPreffiled {
                    return Just<Void>.withErrorType(Error.self)
                } else {
                    return self.prefillDBWithTests()
                }
            }
            .flatMap { [dbRepository] in
                dbRepository.tests(for: "Autism Spectrum Disorders")
            }
            .sinkToLoadable { tests.wrappedValue = $0 }
            .store(in: cancelBag)
    }

    func select(answer: Test.Answer, in questions: [Test.Question]) {
        var updatedQuestions = questions
        guard let question = questions.first(where: { $0.answers.contains(where: { $0.id == answer.id }) }) else {
            return
        }
        let newQuestion = Test.Question(title: question.title, type: question.type, order: question.order, id: question.id, answers: [answer])
        let questionIndex = questions.firstIndex(where: { $0.id == question.id })
        if let index = questionIndex {
            updatedQuestions.remove(at: index)
            updatedQuestions.insert(newQuestion, at: index)
        } else {
            updatedQuestions.append(newQuestion)
        }
        let index = questionIndex ?? 0
        appState.bulkUpdate {
            $0.routing.questions.questionID = questions[index + 1].id
        }        
    }

    func currentQuestion(for testResult: TestResult) -> Test.Question? {
        let answeredQuestion = testResult.questions.first(where: { $0.id == appState.value.routing.questions.questionID })
        let nextQuestion = testResult.test.questions.first(where: { $0.id == appState.value.routing.questions.questionID })
        let question = answeredQuestion ?? nextQuestion
        appState.bulkUpdate {
            $0.routing.questions.questionID = question?.id
        }
        return question
    }

    func prefillDBWithTests() -> AnyPublisher<Void, Error> {
        return jsonRepository
            .getTests()
            .flatMap { [dbRepository] in
                dbRepository.store(categories: $0)
            }
            .eraseToAnyPublisher()
    }
}

struct StubTestSelectorInteractor: TestSelectorInteractor {
    func load(tests: LoadableSubject<LazyList<Test>>) {

    }

    func select(answer: Test.Answer, in questions: [Test.Question]) {

    }

    func currentQuestion(for testResult: TestResult) -> Test.Question? {
        return nil
    }
}
