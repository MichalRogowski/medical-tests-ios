//
//  Lottie.swift
//  Autism Test
//
//  Created by Michał Rogowski on 29/08/2021.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    let name: String
    @Binding var progress: Float
    let view = UIView(frame: .zero)

    private var animationView: AnimationView {
        let animationView = AnimationView()
        let animation = Animation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .forceFinish
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<LottieView>) {
        let oldProgress = (uiView.subviews.first as? AnimationView)?.currentProgress
        uiView.subviews.forEach { $0.removeFromSuperview() }
        let animationView = animationView
        uiView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: uiView.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: uiView.widthAnchor)
        ])
        let newValue = (CGFloat(progress) * 100).rounded() / 100
        let oldValue = ((oldProgress ?? 0) * 100).rounded() / 100
        animationView.currentProgress = oldValue
        if newValue > oldValue {
            animationView.play(fromProgress: oldValue, toProgress: newValue)
        } else {
            animationView.currentProgress = newValue
        }
    }
}

struct LottieButton: UIViewRepresentable {

    typealias UIViewType = UIView
    let animatedButton = AnimatedButton()
    let filename: String
    let action: () -> Void

    func makeUIView(context: UIViewRepresentableContext<LottieButton>) -> UIView {
        let view = UIView()

        let animation = Animation.named(filename)
        animatedButton.animation = animation
        animatedButton.contentMode = .scaleAspectFit

        animatedButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animatedButton)

        NSLayoutConstraint.activate([
            animatedButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            animatedButton.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieButton>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }


    class Coordinator: NSObject {
        let parent: LottieButton

        init(_ parent: LottieButton) {
            self.parent = parent
            super.init()
            parent.animatedButton.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        }

        // this function can be called anything, but it is best to make the names clear
        @objc func touchUpInside() {
            parent.action()
        }
    }
}
