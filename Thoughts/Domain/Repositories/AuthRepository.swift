//
//  AuthRepository.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

protocol AuthRepository {
    
    var userIdPublisher: AnyPublisher<String?, Never> { get }
    
    var userId: String? { get }
    
    func register(email: String, password: String) -> AnyPublisher<String, Error>
    
    func signIn(email: String, password: String) -> AnyPublisher<String, Error>
}
