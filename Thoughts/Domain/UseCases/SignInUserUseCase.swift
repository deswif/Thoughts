//
//  SignInUseCase.swift
//  Thoughts
//
//  Created by Max Steshkin on 19.09.2023.
//

import Foundation
import Combine

class SignInUserUseCase: UseCaseWithParams {
    
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func call(with params: Params) -> AnyPublisher<Void, Error> {
        authRepository.signIn(email: params.email, password: params.password)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
    
    struct Params {
        let email: String
        let password: String
    }
}
