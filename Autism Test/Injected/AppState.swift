//
//  AppState.swift
//  Autism Test
//
//  Created by Michał Rogowski on 28/08/2021.
//


import SwiftUI
import Combine

class AppState: ObservableObject, Equatable {
    @Published var userData = UserData()
    @Published var routing = ViewRouting()
    @Published var system = System()
}

extension AppState {
    struct UserData: Equatable {

    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var testsList = TestsList.Routing()
        var testIntro = TestIntro.Routing()
        var questions = QuestionsView.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
        var keyboardHeight: CGFloat = 0
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.userData == rhs.userData &&
        lhs.routing == rhs.routing &&
        lhs.system == rhs.system
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        let state = AppState()
        state.system.isActive = true
        return state
    }
}
#endif
