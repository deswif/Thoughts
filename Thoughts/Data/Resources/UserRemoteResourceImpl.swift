//
//  UserResource.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import FirebaseFirestore
import Combine

class UserRemoteResourceImpl: UserRemoteResource {
    
    init() {
        firestore = Firestore.firestore()
        usersCollection = firestore.collection("users")
    }
    
    private let firestore: Firestore
    private let usersCollection: CollectionReference
    
    func create(_ info: CreateUserInfo) -> AnyPublisher<Void, Error> {
        usersCollection.document(info.id).setData([
            "email": info.email,
            "password": info.password,
            "username": info.username,
            "name": info.name,
            "createTimestamp": FieldValue.serverTimestamp()
        ])
        .eraseToAnyPublisher()
    }
    
    func read(id: String) -> AnyPublisher<User, Error> {
        usersCollection.document("id").getDocument()
            .tryMap { try UserMapper.user(from: $0) }
            .eraseToAnyPublisher()
    }
    
    func userPublisher(for id: String) -> AnyPublisher<User, Error> {
        usersCollection.document(id).publisher()
            .tryMap { try UserMapper.user(from: $0) }
            .eraseToAnyPublisher()
    }
}
