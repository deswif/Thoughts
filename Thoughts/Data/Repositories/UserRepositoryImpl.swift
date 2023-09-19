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
    private let userSubject = CurrentValueSubject<User, Never>(.empty)
    
    private var bag = Set<AnyCancellable>()
    
    private var id: String!
    
    init(remoteResource: UserRemoteResource? = nil) {
        self.remoteResource = remoteResource ?? DIContainer.shared.inject(type: UserRemoteResource.self)
    }
    
    var publisher: AnyPublisher<User, Never> {
        userSubject.eraseToAnyPublisher()
    }
    
    func create(_ info: CreateUserInfo) -> AnyPublisher<Void, Error> {
        remoteResource.create(info)
    }
    
    func current() -> AnyPublisher<User, Error> {
        if userSubject.value.isEmpty {
            return remoteResource.read(id: id).handleEvents(receiveOutput: { user in
                self.userSubject.send(user)
            }).eraseToAnyPublisher()
        }
        return Just(userSubject.value)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func bind(id: String) {
        self.id = id
    }
    
    func unbind() {
        userSubject.send(User.empty)
        self.id = nil
    }
}
