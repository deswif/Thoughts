//
//  AuthViewModel.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import Foundation
import Combine

class RegisterViewModel: ViewModel {
    
    func transform(events: Events) -> States {
        let buttonAvailable = events.emailText.combineLatest(events.passwordText, events.nicknameText, events.nameText) { [self] email, password, nickname, name in
            return valid(email: email) && valid(password: password) && valid(nickname: nickname) && valid(name: name)
        }.removeDuplicates().eraseToAnyPublisher()
        
        let loadingProcessing = PassthroughSubject<Bool, Never>().eraseToAnyPublisher()
        
        let errorMessages = events.registerClicks.map { _ in ErrorMessage.unknown }.eraseToAnyPublisher()
        
        return States(errorMessages: errorMessages, buttonAvailable: buttonAvailable, loadingProcessing: loadingProcessing)
    }
    
    private func valid(email: String) -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func valid(password: String) -> Bool {
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return password.count >= 6
    }
    
    private func valid(nickname: String) -> Bool {
        let nickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9a-z\\_\\.]{4,20}$", options: .caseInsensitive)
            if regex.matches(in: nickname, options: [], range: NSMakeRange(0, nickname.count)).count > 0 {
                return true
            }
        } catch {}
        return false
    }
    
    private func valid(name: String) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension RegisterViewModel {
    struct States {
        let errorMessages: AnyPublisher<ErrorMessage, Never>
        let buttonAvailable: AnyPublisher<Bool, Never>
        let loadingProcessing: AnyPublisher<Bool, Never>
    }
    
    struct Events {
        let emailText: AnyPublisher<String, Never>
        let passwordText: AnyPublisher<String, Never>
        let nicknameText: AnyPublisher<String, Never>
        let nameText: AnyPublisher<String, Never>
        let registerClicks: AnyPublisher<FieldsInfo, Never>
    }
}

extension RegisterViewModel {
    enum ErrorMessage {
        case unknown
        
        func description() -> String {
            switch (self) {
            case .unknown:
                return "Unknown error. Try later"
            }
        }
    }
    
    struct FieldsInfo {
        let email: String
        let password: String
        let nickname: String
        let name: String
    }
}
