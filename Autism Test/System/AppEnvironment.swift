//
//  AppEnvironment.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//

import UIKit
import Combine

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {

    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())

        let dbRepositories = configuredDBRepositories(appState: appState)
        let interactors = configuredInteractors(appState: appState,
                                                dbRepositories: dbRepositories)
        let diContainer = DIContainer(appState: appState, interactors: interactors)
        return AppEnvironment(container: diContainer)
    }

    private static func configuredDBRepositories(appState: Store<AppState>) -> DIContainer.DBRepositories {
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let testsDBRepository = RealTestDBRepository(persistentStore: persistentStore)
        let jsonRepository = RealJSONRepository()
        return .init(testsDBRepository: testsDBRepository, jsonRepository: jsonRepository)
    }

    private static func configuredInteractors(appState: Store<AppState>, dbRepositories: DIContainer.DBRepositories
    ) -> DIContainer.Interactors {

        let interactor = RealTestSelectorInteractor(dbRepository: dbRepositories.testsDBRepository, jsonRepository: dbRepositories.jsonRepository, appState: appState)

        return .init(testSelectorInteractor: interactor)
    }
}

extension DIContainer {
    struct DBRepositories {
        let testsDBRepository: TestsDBRepository
        let jsonRepository: JSONRepository
    }
}

