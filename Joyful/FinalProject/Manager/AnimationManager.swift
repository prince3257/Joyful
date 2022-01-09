//
//  AnimationManager.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/14.
//

import Foundation
import Lottie

struct AnimationManager {
    
    static var shared = AnimationManager()
    
    private init() {}
    
    func normalAnimation(view: AnimationView, animationName: String) {
        let animation = Animation.named(animationName)
        view.animation = animation
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 0.8
        view.play(completion: nil)
    }
    
    func resume(view: AnimationView) {
        view.play(completion: nil)
    }
    
}
