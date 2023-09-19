//
//  User.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation

struct User {
    let id: String
    let email: String
    let password: String
    let username: String
    let name: String
    let createdAt: Date
    
    static var empty: User {
        User(id: "", email: "", password: "", username: "", name: "", createdAt: Date.now)
    }
    
    var isEmpty: Bool {
        self.id == ""
    }
}
