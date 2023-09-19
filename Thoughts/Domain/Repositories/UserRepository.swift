//
//  UserRepository.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

protocol UserRepository {
    var publisher: AnyPublisher<User, Never> { get }
    
    func create(_ info: CreateUserInfo) -> AnyPublisher<Void, Error>
    
    func current() -> AnyPublisher<User, Error>
    
    func bind(id: String)
    
    func unbind()
}
