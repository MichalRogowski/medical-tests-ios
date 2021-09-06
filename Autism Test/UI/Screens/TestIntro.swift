//
//  TestIntro.swift
//  Autism Test
//
//  Created by Michał Rogowski on 29/08/2021.
//

import SwiftUI
import Combine

struct TestIntro: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var test: Loadable<Test>
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.testIntro)
    }

    init(test: Test) {
        self._test = .init(initialValue: .loaded(test))
    }

    var body: some View {
        content
            .navigationTitle("Summary")
            .onReceive(routingUpdate) { self.routingState = $0 }
    }

    private var content: AnyView {
        switch test {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(countryDetails): return AnyView(loadedView(countryDetails))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Side Effects

private extension TestIntro {
    func start(test: Test) {
        injected.appState[\.routing.testIntro.questionsView] = true
    }
}
// MARK: - Loading Content

private extension TestIntro {
    var notRequestedView: some View {
        Text("Test not requested")
    }

    var loadingView: some View {
        VStack {
            ActivityIndicatorView()
        }
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {})
    }
}

// MARK: - Displaying Content
    
private extension TestIntro {
    func loadedView(_ test: Test) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 5) {
                Text(test.title)
                    .font(.headline)
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                testSectionView(title: "Description", description: test.subtitle)
                NavigationLink(destination: questionsView(test: test),
                               isActive: $routingState.questionsView) {
                    Text("Start")
                }
                .padding()
                .buttonStyle(RoundedRectangleButtonStyle())
                .font(.headline)
                testSectionView(title: "Scoring Key", description: test.scoringKey)
                testSectionView(title: "Source", description: test.source)
                Text("All tests are indicative only and do not form a formal diagnosis. We are not medical or psychiatric professionals. The information provided are for educational and entertainment purposes only. The assessments on this website are not intended to diagnose any disease or condition and should not be solely relied on, even by mental health or health care professionals, for this or any similar purpose.")
                    .font(.caption)
                    .padding()

            }
        }
    }

    func questionsView(test: Test) -> some View {
        let view = QuestionsView(test: test)
            .inject(injected)

        injected.appState.value.routing.questions.questionID = test.questions.first?.id
        return view
    }

    func testSectionView(title: String, description: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            VStack {
                Spacer(minLength: 4)
                Text(description)
                    .font(.body)
                Spacer(minLength: 4)
            }
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            .background(Color.secondary.opacity(0.1))
        }
    }
}

// MARK: - Routing

extension TestIntro {
    struct Routing: Equatable {
        var questionsView: Bool = false
    }
}

// MARK: - State Updates

private extension TestIntro {

    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.testIntro)
    }
}

// MARK: - Preview

#if DEBUG
struct TestIntro_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
//        TestIntro(country: )
//            .inject(.preview)
    }
}
#endif
