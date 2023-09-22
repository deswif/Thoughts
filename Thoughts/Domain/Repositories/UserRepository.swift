//
//  UserRepository.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

protocol UserRepository {
    func create(_ info: CreateUserInfo) -> AnyPublisher<Void, Error>
    
    func read(with id: String) -> AnyPublisher<User, Error>
    
    func userPublisher(for id: String) -> AnyPublisher<User, Error>
}
