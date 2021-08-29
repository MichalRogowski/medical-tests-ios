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
    func start(test: Test)
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

    func start(test: Test) {
        
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

    func start(test: Test) {

    }
}
