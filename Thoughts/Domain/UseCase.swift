//
//  UseCase.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

protocol UseCase {
    associatedtype R
    associatedtype E: Error
    
    func call() -> AnyPublisher<R, E>
}

protocol UseCaseWithParams {
    associatedtype P
    associatedtype R
    associatedtype E: Error
    
    func call(with params: P) -> AnyPublisher<R, E>
}
