//
//  UserRemote.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

protocol UserRemoteResource {
    func create(_ info: CreateUserInfo) -> AnyPublisher<Void, Error>
    
    func read(id: String) -> AnyPublisher<User, Error>
    
    func userPublisher(for id: String) -> AnyPublisher<User, Error>
}
