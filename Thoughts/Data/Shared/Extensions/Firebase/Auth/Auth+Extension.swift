//
//  Auth+Extension.swift
//  Thoughts
//
//  Created by Max Steshkin on 20.09.2023.
//

import Foundation
import Combine
import FirebaseAuth


extension Auth {
    
    public var stateDidChangePublisher: AnyPublisher<FirebaseAuth.User?, Never> {
        StateDidChangePublisher(self)
            .eraseToAnyPublisher()
    }
    
    public func createUser(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
        Future<AuthDataResult, Error> { [weak self] promise in
            self?.createUser(withEmail: email, password: password) { auth, error in
                if let error = error {
                    promise(.failure(error))
                } else if let auth = auth {
                    promise(.success(auth))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func signIn(withEmail email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
        Future<AuthDataResult, Error> { [weak self] promise in
            self?.signIn(withEmail: email, password: password) { auth, error in
                if let error = error {
                    promise(.failure(error))
                } else if let auth = auth {
                    promise(.success(auth))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension Auth {
    private struct StateDidChangePublisher: Combine.Publisher {
        typealias Output = FirebaseAuth.User?
        typealias Failure = Never
        
        private let auth: Auth
        
        init(_ auth: Auth) {
            self.auth = auth
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, StateDidChangePublisher.Failure == S.Failure, StateDidChangePublisher.Output == S.Input {
            let subscription = FirebaseAuth.User.AuthStateDidChangeSubscription(subcriber: subscriber, auth: auth)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension FirebaseAuth.User {
    fileprivate final class AuthStateDidChangeSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == FirebaseAuth.User? {
        
        var handler: AuthStateDidChangeListenerHandle?
        var auth: Auth?
        
        init(subcriber: SubscriberType, auth: Auth) {
            self.auth = auth
            handler = auth.addStateDidChangeListener { (_, user) in
                _ = subcriber.receive(user)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            if let handler = handler {
                auth?.removeStateDidChangeListener(handler)
            }
            handler = nil
            auth = nil
        }
    }
}
