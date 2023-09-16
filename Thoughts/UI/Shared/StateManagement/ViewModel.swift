//
//  Base.swift
//  Thoughts
//
//  Created by Max Steshkin on 16.09.2023.
//

import Combine

protocol ViewModel {
    
    associatedtype E
    associatedtype S
    
    func transform(events: E) -> S
}
