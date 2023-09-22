//
//  AuthViewModel.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import Foundation
import Combine

class RegisterViewModel {
    
    private let createUser: CreateUserUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    private let emailTextEvents = PassthroughSubject<String, Never>()
    private let passwordTextEvents = PassthroughSubject<String, Never>()
    private let usernameTextEvents = PassthroughSubject<String, Never>()
    private let nameTextEvents = PassthroughSubject<String, Never>()
    private let registerClickEvents = PassthroughSubject<FieldsInfo, Never>()
    
    private let errorMessagesSubject = PassthroughSubject<ErrorMessage, Never>()
    private let buttonAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    private let loadingProcessingSubject = CurrentValueSubject<Bool, Never>(false)
    
    
    var errorMessagesState: AnyPublisher<ErrorMessage, Never> {
        errorMessagesSubject.eraseToAnyPublisher()
    }
    
    var buttonAvailableState: AnyPublisher<Bool, Never> {
        buttonAvailableSubject.eraseToAnyPublisher()
    }
    
    var loadingProcessingState: AnyPublisher<Bool, Never> {
        loadingProcessingSubject.eraseToAnyPublisher()
    }
    
    
    func emailChanged(to email: String) {
        emailTextEvents.send(email)
    }
    
    func passwordChanged(to password: String) {
        passwordTextEvents.send(password)
    }
    
    func usernameChanged(to nickname: String) {
        usernameTextEvents.send(nickname)
    }
    
    func nameChanged(to name: String) {
        nameTextEvents.send(name)
    }
    
    func registerPressed(with info: FieldsInfo) {
        registerClickEvents.send(info)
    }
    
    
    init(createUser: CreateUserUseCase) {
        self.createUser = createUser
        
        listenFields()
    }
    
    func listenFields() {
        emailTextEvents
            .combineLatest(passwordTextEvents, usernameTextEvents, nameTextEvents) { email, password, username, name in
                FieldValidators.valid(email: email) &&
                FieldValidators.valid(password: password) &&
                FieldValidators.valid(username: username) &&
                FieldValidators.valid(name: name)
            }
            .removeDuplicates()
            .sink { self.buttonAvailableSubject.send($0) }
            .store(in: &cancellables)
    }
    
    func listenClicks() {
        registerClickEvents
            .filter { info in
                FieldValidators.valid(email: info.email) &&
                FieldValidators.valid(password: info.password) &&
                FieldValidators.valid(username: info.username) &&
                FieldValidators.valid(name: info.name)
            }
            .sink { [self] info in
                loadingProcessingSubject.send(true)
                createUser.call(with: .init(email: info.email, password: info.password, username: info.username, name: info.name))
                    .subscribe(on: WorkScheduler.backgroundWorkScheduler)
                    .receive(on: WorkScheduler.mainScheduler)
                    .timeout(10, scheduler: WorkScheduler.mainScheduler, customError: { TimeoutError() })
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print(error)
                            self?.errorMessagesSubject.send(.unknown)
                            break
                        }
                        self?.loadingProcessingSubject.send(false)
                    } receiveValue: { _ in }
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
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
