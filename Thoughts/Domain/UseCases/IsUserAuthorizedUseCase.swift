//
//  IsAuthenticatedUseCase.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

class IsUserAuthorizedUseCase: UseCase {
    
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func call() -> AnyPublisher<Bool, Never> {
        Just(authRepository.userId != nil).eraseToAnyPublisher()
    }
}
