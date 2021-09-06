//
//  RoundedRectangleButtonStyle.swift
//  Autism Test
//
//  Created by Michał Rogowski on 30/08/2021.
//

import SwiftUI

struct RoundedRectangleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        MyButton(configuration: configuration)
    }

    struct MyButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            HStack {
                Spacer()
                configuration.label.foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(isEnabled ? Color.purple.cornerRadius(8): Color.purple.opacity(0.5).cornerRadius(8))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
        }
    }

}
