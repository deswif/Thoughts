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
        return Future<Void, Error> { promise in
            self.usersCollection.document(info.id).setData([
                "email": info.email,
                "password": info.password,
                "username": info.username,
                "name": info.name,
                "createTimestamp": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                promise(.success())
            }
        }.eraseToAnyPublisher()
    }
    
    func read(id: String) -> AnyPublisher<User, Error> {
        Future<User, Error> { [self] promise in
            usersCollection.document(id).getDocument { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let doc = result else {
                    promise(.failure(UserNotFoundError()))
                    return
                }
                
                do {
                    let user = try UserMapper.user(from: doc)
                    promise(.success(user))
                } catch (let error) {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
