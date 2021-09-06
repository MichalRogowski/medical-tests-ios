//
//  SingleSelectRow.swift
//  Autism Test
//
//  Created by Michał Rogowski on 29/08/2021.
//

import SwiftUI

struct SingleSelectRow: View {

    let answer: Test.Answer
    @Binding var selectedAnswer: Test.Answer?
    let action: () -> Void

    @State private var progress: Float = 0

    private var isSelected: Bool {
        $selectedAnswer.wrappedValue?.id == answer.id
    }

    var body: some View {
        let lottieView = LottieView(name: "confirmation-tick", progress: $progress)
        VStack(alignment: .leading) {
            Spacer()
            HStack(alignment: .center, spacing: 8) {
                lottieView
                    .frame(width: 30, height: 30)
                Text(answer.title)
                Spacer()
            }
            Spacer()
            Divider()
        }
        .onTapGesture {
            selectAnswer()
        }
        .onAppear(perform: {
            updateProgress()
        })
        .onReceive(selectedAnswer.publisher) { _ in
            updateProgress()
        }
    }
}

// MARK: - Side Effects

private extension SingleSelectRow {
    func selectAnswer() {
        guard isSelected == false else {
            return
        }
        action()
    }

    func updateProgress() {
        if isSelected {
            progress = 1
        } else {
            progress = 0.32
        }
    }
}

struct SingleSelectRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("sfa")
//        SingleSelectRow(answer: Test.Answer(title: "Would you like to eat banana", value: 1, id: UUID(), order: 0), selectedAnswerID: nil) {
//
//        }
    }
}
