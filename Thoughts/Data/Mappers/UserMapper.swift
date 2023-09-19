//
//  UserMapper.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import FirebaseFirestore

class UserMapper {
    static func user(from doc: DocumentSnapshot) throws -> User {
        
        guard let data = doc.data() else {
            throw UserNotFoundError()
        }
        
        guard
            let email = data["email"] as? String,
            let password = data["password"] as? String,
            let username = data["username"] as? String,
            let name = data["name"] as? String,
            let createTimestamp = data["createTimestamp"] as? Timestamp
        else {
            throw UserInvalidDataFormatError()
        }
        
        return User(id: doc.documentID, email: email, password: password, username: username, name: name, createdAt: createTimestamp.dateValue())
    }
}
