//
//  AttitudeQuestion.swift
//  Autism Test
//
//  Created by Michał Rogowski on 29/08/2021.
//

import SwiftUI

struct AttitudeQuestion: View {

    let question: Test.Question
    @State private var selectedAnswer: Test.Answer?
    let answerSubmitted: (Test.Answer) -> ()

    init(question: Test.Question, answerSubmitted: @escaping (Test.Answer) -> ()) {
        self.question = question
        self.answerSubmitted = answerSubmitted
    }

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) {
                Text(question.title)
                    .font(.headline)
                ForEach(question.answers) { answer in
                    SingleSelectRow(answer: answer, selectedAnswer: $selectedAnswer) {
                        selectAnswer(answer: answer)
                    }
                }
            }
            Button("Next") {
                submitAnswer()
            }
            .font(.headline)
            .disabled(selectedAnswer == nil)
            .buttonStyle(RoundedRectangleButtonStyle())
        }
        .padding()
    }
}


// MARK: - Side Effects

private extension AttitudeQuestion {
    func selectAnswer(answer: Test.Answer) {
        selectedAnswer = answer
    }

    func submitAnswer() {
        guard let answer = selectedAnswer else {
            return
        }        
        answerSubmitted(answer)
    }
}

struct AttitudeQuestion_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
//        AttitudeQuestion()
    }
}
