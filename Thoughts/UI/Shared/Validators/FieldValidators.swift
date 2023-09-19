//
//  StringValidators.swift
//  Thoughts
//
//  Created by Max Steshkin on 19.09.2023.
//

import Foundation

class FieldValidators {
    static func valid(email: String) -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func valid(password: String) -> Bool {
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return password.count >= 6
    }
    
    static func valid(username: String) -> Bool {
        let nickname = username.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9a-z\\_\\.]{4,20}$", options: .caseInsensitive)
            if regex.matches(in: username, options: [], range: NSMakeRange(0, username.count)).count > 0 {
                return true
            }
        } catch {}
        return false
    }
    
    static func valid(name: String) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
