//
//  InteractorsContainer.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

extension DIContainer {
    struct Interactors {
        let testSelectorInteractor: TestSelectorInteractor

        init(testSelectorInteractor: TestSelectorInteractor) {
            self.testSelectorInteractor = testSelectorInteractor
        }

        static var stub: Self {
            .init(testSelectorInteractor: StubTestSelectorInteractor())
        }
    }
}
