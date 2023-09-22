//
//  BusinessLogicResolver.swift
//  Thoughts
//
//  Created by Max Steshkin on 16.09.2023.
//

import Combine

class BusinessLogicResolver<E> {
    
    private var bag = Set<AnyCancellable>()
    
    private var eventSubjects: [String: PassthroughSubject<E, Never>] = [:]
    
    private var transformers: [String: Transformer] = [:]
    
    typealias Transformer = (AnyPublisher<E, Never>) -> AnyPublisher<E, Never>
    
    func on(_ event: E.Type, do action: @escaping (E) -> Void, transformer: Transformer? = nil) {
        let transformer = transformer ?? { $0 }
        let subject = PassthroughSubject<E, Never>()
        
        transformer(subject.eraseToAnyPublisher()).sink(receiveValue: action).store(in: &bag)
        
        transformers[eventToString(event)] = transformer
        eventSubjects[eventToString(event)] = subject
    }
    
    func add(_ event: E) {
        eventSubjects[eventToString(event as! E.Type)]?.send(event)
    }
    
    private func eventToString(_ eventType: E.Type) -> String {
        return "\(eventType)"
    }
}
