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
        StateDidChangePublisher(Auth.auth())
            .eraseToAnyPublisher()
    }
    
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func register(email: String, password: String) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { auth, error in
                if let error = error {
                    promise(.failure(error))
                } else if let auth = auth {
                    promise(.success(auth.user.uid))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { auth, error in
                if let error = error {
                    promise(.failure(error))
                } else if let auth = auth {
                    promise(.success(auth.user.uid))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension AuthRepositoryImpl {
    private struct StateDidChangePublisher: Combine.Publisher {
        typealias Output = String?
        typealias Failure = Never
        
        private let auth: Auth
        
        init(_ auth: Auth) {
            self.auth = auth
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, StateDidChangePublisher.Failure == S.Failure, StateDidChangePublisher.Output == S.Input {
            let subscription = User.AuthStateDidChangeSubscription(subcriber: subscriber, auth: auth)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension User {
    fileprivate final class AuthStateDidChangeSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == String? {
        
        var handler: AuthStateDidChangeListenerHandle?
        var auth: Auth?
        
        init(subcriber: SubscriberType, auth: Auth) {
            self.auth = auth
            handler = auth.addStateDidChangeListener { (_, user) in
                _ = subcriber.receive(user?.uid)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            // We do nothing here as we only want to send events when they occur.
            // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
        }
        
        func cancel() {
            if let handler = handler {
                auth?.removeStateDidChangeListener(handler)
            }
            handler = nil
            auth = nil
        }
    }
}
