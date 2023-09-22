//
//  AuthCoordinator.swift
//  Thoughts
//
//  Created by Max Steshkin on 22.09.2023.
//

import UIKit

class AuthCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    
    var authRepository: AuthRepository!
    var userRepository: UserRepository!
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let authVC = makeAuthViewController()
        navigationController.setViewControllers([authVC], animated: true)
    }
    
    func registerAccount() {
        let vc = makeRegisterViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func signIn() {
        let vc = makeLoginViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func makeAuthViewController() -> AuthViewController {
        let vc = AuthViewController()
        vc.coordinator = self
        
        return vc
    }
    
    func makeRegisterViewController() -> RegisterViewController {
        let createUserUseCase = CreateUserUseCase(authRepository: authRepository, userRepository: userRepository)
        let viewModel = RegisterViewModel(createUser: createUserUseCase)
        let vc = RegisterViewController(viewModel: viewModel)
        
        return vc
    }
    
    func makeLoginViewController() -> LoginViewController {
        let signInUser = SignInUserUseCase(authRepository: authRepository)
        let viewModel = LoginViewModel(signInUserUseCase: signInUser)
        let vc = LoginViewController(viewModel: viewModel)
        
        return vc
    }
}
