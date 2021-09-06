//
//  QuestionsView.swift
//  Autism Test
//
//  Created by Michał Rogowski on 29/08/2021.
//

import SwiftUI
import Combine

struct QuestionsView: View {

    @Environment(\.injected) private var injected: DIContainer
    @State private var routingState: Routing = .init(questionID: nil)
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.questions)
    }
    private var testResult: TestResult
    init(test: Test) {
        self.testResult = TestResult(date: Date(), test: test, id: UUID(), questions: [])
    }
    
    var body: some View {
        questionsView()
            .onReceive(routingUpdate) {
                routingState = $0
            }
            .navigationTitle("Question 1/50")
    }
}

// MARK: - Displaying Content

private extension QuestionsView {
    func questionsView() -> some View {
        if let question = injected.interactors.testSelectorInteractor.currentQuestion(for: testResult) {
            switch question.type {
            case .attitude:
                return AnyView(
                    AttitudeQuestion(question: question) { answer in
                        submitAnswer(answer: answer)
                    }
                )
            }
        } else {
            return AnyView(Text("No questions available"))
        }
    }
}

// MARK: - State Updates

private extension QuestionsView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.questions)
    }
}

// MARK: - Side Effects

private extension QuestionsView {
    func submitAnswer(answer: Test.Answer) {
        injected.interactors.testSelectorInteractor.select(answer: answer, in: testResult.test.questions)
    }
}

// MARK: - Routing

extension QuestionsView {
    struct Routing: Equatable {
        var questionID: UUID?
    }
}

//struct QuestionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuestionsView()
//    }
//}
