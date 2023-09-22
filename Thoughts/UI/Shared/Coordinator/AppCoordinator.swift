//
//  AppCoordinator.swift
//  Thoughts
//
//  Created by Max Steshkin on 22.09.2023.
//

import UIKit
import Combine

class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    unowned let navigationController: UINavigationController
    
    // data sources
    private var userRemoteResource: UserRemoteResource!
    
    // repositories
    private var userRepository: UserRepository!
    private var authRepository: AuthRepository!
    
    private var bag = Set<AnyCancellable>()
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        userRemoteResource = UserRemoteResourceImpl()
        
        userRepository = UserRepositoryImpl(remoteResource: userRemoteResource)
        authRepository = AuthRepositoryImpl()
        
        let isUserAuthorized = IsUserAuthorizedUseCase(authRepository: authRepository)
        isUserAuthorized.call().sink { [self] authorized in
            authChanged(authorized)
        }.store(in: &bag)
        
        let listeAuth = ListenAuthUseCase(authRepository: authRepository)
        listeAuth.call().sink { [self] authorized in
            authChanged(authorized)
        }.store(in: &bag)
    }
    
    func authChanged(_ authorized: Bool) {
        if authorized {
            childCoordinators.removeAll()
            let feedVC = makeFeedController()
            navigationController.setViewControllers([feedVC], animated: true)
        } else {
            startAuthCoordinator()
        }
    }
    
    private func startAuthCoordinator() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.authRepository = authRepository
        authCoordinator.userRepository = userRepository
        
        childCoordinators.removeAll()
        childCoordinators.append(authCoordinator)
        
        authCoordinator.start()
    }
    
    private  func makeFeedController() -> FeedViewController {
        return FeedViewController()
    }
}
