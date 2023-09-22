//
//  ListenAuthUseCase.swift
//  Thoughts
//
//  Created by Max Steshkin on 22.09.2023.
//

import Combine

class ListenAuthUseCase: UseCase {
    
    let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func call() -> AnyPublisher<Bool, Never> {
        authRepository
            .userIdPublisher
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }
    
}
