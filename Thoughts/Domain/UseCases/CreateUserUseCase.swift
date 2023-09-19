//
//  CreateUserUseCase.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

class CreateUserUseCase: UseCaseWithParams {
    
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private var bag = Set<AnyCancellable>()
    
    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    func call(with params: Params) -> AnyPublisher<Void, Error> {
        authRepository.register(email: params.email, password: params.password)
            .map { userId in
                return self.userRepository.create(
                    CreateUserInfo(
                        id: userId,
                        email: params.email,
                        password: params.password,
                        username: params.username,
                        name: params.name
                    )
                )
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    struct Params {
        let email: String
        let password: String
        let username: String
        let name: String
    }
}
