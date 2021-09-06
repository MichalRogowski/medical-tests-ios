//
//  TestsList.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import SwiftUI
import Combine

struct TestsList: View {

    @State private(set) var tests: Loadable<LazyList<Test>>
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.testsList)
    }

    @EnvironmentObject var appState: AppState
    @Environment(\.injected) private var injected: DIContainer

    init(countries: Loadable<LazyList<Test>> = .notRequested) {
        self._tests = .init(initialValue: countries)
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                self.content
                    .navigationBarTitle("Autism Spectrum", displayMode: .inline)
                    .animation(.easeOut(duration: 0.3))
            }
            .accentColor(.purple)
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
    }

    private var content: AnyView {
        switch tests {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last, _): return AnyView(loadingView(last))
        case let .loaded(tests): return AnyView(loadedView(tests, showLoading: false))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Routing

extension TestsList {
    struct Routing: Equatable {
        var testID: UUID?
    }
}

// MARK: - State Updates

private extension TestsList {

    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.testsList)
    }
}

// MARK: - Loading Content

private extension TestsList {
    var notRequestedView: some View {
        Text("").onAppear(perform: loadTests)
    }

    func loadingView(_ previouslyLoaded: LazyList<Test>?) -> some View {
        if let tests = previouslyLoaded {
            return AnyView(loadedView(tests, showLoading: true))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadTests()
        })
    }
}

private extension TestsList {
    func loadedView(_ countries: LazyList<Test>, showLoading: Bool) -> some View {
        VStack {
            if showLoading {
                ActivityIndicatorView().padding()
            }
            List(countries) { test in
                NavigationLink(
                    destination: self.detailsView(test: test),
                    tag: test.id,
                    selection: self.routingBinding.testID) {
                        Text(test.title)
                            .font(.headline)
                            .padding(2)
                    }
            }
            .listStyle(InsetGroupedListStyle())
            .id(countries.count)
            Spacer()
            Text("Tests are available for free on https://psychology-tools.com/test")
                .font(.caption)
        }.padding(.bottom)
    }

    func detailsView(test: Test) -> some View {
        TestIntro(test: test)            
    }
}

// MARK: - Side Effects

private extension TestsList {
    func loadTests() {
        injected.interactors.testSelectorInteractor
            .load(tests: $tests)
    }
}

#if DEBUG
struct TestsList_Previews: PreviewProvider {
    static var previews: some View {
        TestsList(countries: .loaded([].lazyList))
            .inject(.preview)
    }
}
#endif
