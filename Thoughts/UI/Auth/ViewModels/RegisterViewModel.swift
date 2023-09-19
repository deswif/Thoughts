//
//  AuthViewModel.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import Foundation
import Combine

class RegisterViewModel: ViewModel {
    
    private let createUser: CreateUserUseCase
    
    private let errorMessagesSubject = PassthroughSubject<ErrorMessage, Never>()
    private let buttonAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    private let loadingProcessing = CurrentValueSubject<Bool, Never>(false)
    
    private var onSignUp: () -> Void
    
    private var cancellables = Set<AnyCancellable>()
    
    init(createUser: CreateUserUseCase, onSignUp: @escaping () -> Void) {
        self.createUser = createUser
        self.onSignUp = onSignUp
    }
    
    func transform(events: Events) -> States {
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        events.emailText
            .combineLatest(events.passwordText, events.usernameText, events.nameText) { email, password, username, name in
                FieldValidators.valid(email: email) &&
                FieldValidators.valid(password: password) &&
                FieldValidators.valid(username: username) &&
                FieldValidators.valid(name: name)
            }
            .removeDuplicates()
            .sink { self.buttonAvailableSubject.send($0) }
            .store(in: &cancellables)
        
        events.registerClicks
            .filter { info in
                FieldValidators.valid(email: info.email) &&
                FieldValidators.valid(password: info.password) &&
                FieldValidators.valid(username: info.username) &&
                FieldValidators.valid(name: info.name)
            }
            .sink { [self] info in
                loadingProcessing.send(true)
                createUser.call(with: .init(email: info.email, password: info.password, username: info.username, name: info.name))
                    .subscribe(on: WorkScheduler.backgroundWorkScheduler)
                    .receive(on: WorkScheduler.mainScheduler)
                    .timeout(10, scheduler: WorkScheduler.mainScheduler)
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print(error)
                            self?.errorMessagesSubject.send(.unknown)
                            break
                        }
                        self?.loadingProcessing.send(false)
                    } receiveValue: { [weak self] _ in
                        self?.buttonAvailableSubject.send(false)
                        self?.onSignUp()
                    }
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
        
        return States(
            errorMessages: errorMessagesSubject.eraseToAnyPublisher(),
            buttonAvailable: buttonAvailableSubject.eraseToAnyPublisher(),
            loadingProcessing: loadingProcessing.eraseToAnyPublisher()
        )
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
        let usernameText: AnyPublisher<String, Never>
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
        let username: String
        let name: String
    }
}
