//
//  AppStarter.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import Foundation
import Combine
import UIKit
import FirebaseAuth

class AppStarter {
    
    let scene: UIScene
    
    private var bag = Set<AnyCancellable>()
    
    init(scene: UIScene) {
        self.scene = scene
    }
    
    func start() -> UIWindow {
        guard let windowScene = scene as? UIWindowScene else { fatalError() }
        let window = UIWindow(windowScene: windowScene)
        
        let isAuthorized = IsUserAuthorizedUseCase(authRepository: DIContainer.shared.inject(type: AuthRepository.self))
        
        isAuthorized.call().sink { [weak self]  isAuthorized in
            if isAuthorized {
                self?.startWithHome(window: window)
            } else {
                self?.startWithAuth(window: window)
            }
        }.store(in: &bag)
        
        return window
    }
    
    private func startWithAuth(window: UIWindow) {
        window.rootViewController = UINavigationController(rootViewController: AuthViewController())
        window.makeKeyAndVisible()
    }
    
    private func startWithHome(window: UIWindow) {
        window.rootViewController = UINavigationController(rootViewController: FeedViewController())
        window.makeKeyAndVisible()
    }
}

