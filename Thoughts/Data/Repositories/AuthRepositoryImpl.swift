//
//  AuthRepositoryImpl.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthRepositoryImpl: AuthRepository {
    
    var userIdPublisher: AnyPublisher<String?, Never> {
        Auth.auth().stateDidChangePublisher.map {
            print($0?.uid)
            return $0?.uid
        }.eraseToAnyPublisher()
    }
    
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func register(email: String, password: String) -> AnyPublisher<String, Error> {
        Auth.auth().createUser(withEmail: email, password: password)
            .map { $0.user.uid }
            .eraseToAnyPublisher()
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<String, Error> {
        Auth.auth().signIn(withEmail: email, password: password)
            .map { $0.user.uid }
            .eraseToAnyPublisher()
    }
}
