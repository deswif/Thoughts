//
//  UserRepositoryImpl.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine
import FirebaseFirestore

class UserRepositoryImpl: UserRepository {
    
    private let remoteResource: UserRemoteResource
    
    init(remoteResource: UserRemoteResource) {
        self.remoteResource = remoteResource
    }
    
    func create(_ info: CreateUserInfo) -> AnyPublisher<Void, Error> {
        remoteResource.create(info)
    }
    
    func read(with id: String) -> AnyPublisher<User, Error> {
        remoteResource.read(id: id)
    }
    
    func userPublisher(for id: String) -> AnyPublisher<User, Error> {
        remoteResource.userPublisher(for: id)
    }
}
