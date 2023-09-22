//
//  LoginViewModel.swift
//  Thoughts
//
//  Created by Max Steshkin on 19.09.2023.
//

import Foundation
import Combine

class LoginViewModel {
    
    private let signInUser: SignInUserUseCase
    
    private var bag = Set<AnyCancellable>()
    
    private let errorMessagesSubject = PassthroughSubject<ErrorMessage, Never>()
    private let buttonAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    private let loadingProcessingSubject = CurrentValueSubject<Bool, Never>(false)
    
    private let emailTextEvents = PassthroughSubject<String, Never>()
    private let passwordTextEvents = PassthroughSubject<String, Never>()
    private let signInClicksEvents = PassthroughSubject<FieldsInfo, Never>()
    
    
    var errorMessagesState: AnyPublisher<ErrorMessage, Never> {
        errorMessagesSubject.eraseToAnyPublisher()
    }
    
    var buttonAvailableState: AnyPublisher<Bool, Never> {
        buttonAvailableSubject.eraseToAnyPublisher()
    }
    
    var loadingProcessingState: AnyPublisher<Bool, Never> {
        loadingProcessingSubject.eraseToAnyPublisher()
    }
    
    
    func emailChanged(to text: String) {
        emailTextEvents.send(text)
    }
    
    func passwordChanged(to text: String) {
        passwordTextEvents.send(text)
    }
    
    func signInPressed(with info: FieldsInfo) {
        signInClicksEvents.send(info)
    }
    
    init(signInUserUseCase: SignInUserUseCase) {
        self.signInUser = signInUserUseCase
        
        listenFieldsChanges()
        listenSignInClicks()
    }
}

extension LoginViewModel {
    private func listenFieldsChanges() {
        emailTextEvents
            .combineLatest(passwordTextEvents) { email, password in
                return FieldValidators.valid(email: email) &&
                FieldValidators.valid(password: password)
            }
            .removeDuplicates()
            .sink { self.buttonAvailableSubject.send($0) }
            .store(in: &bag)
    }
    
    private func listenSignInClicks() {
        signInClicksEvents
            .filter { info in
                FieldValidators.valid(email: info.email) &&
                FieldValidators.valid(password: info.password)
            }
            .sink { [self] info in
                loadingProcessingSubject.send(true)
                signInUser.call(with: .init(email: info.email, password: info.password))
                    .subscribe(on: WorkScheduler.backgroundWorkScheduler)
                    .receive(on: WorkScheduler.mainScheduler)
                    .timeout(10, scheduler: WorkScheduler.mainScheduler, customError: { TimeoutError() })
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(_):
                            self?.errorMessagesSubject.send(.unknown)
                            break
                        }
                        self?.loadingProcessingSubject.send(false)
                    } receiveValue: { _ in }
                    .store(in: &bag)
            }
            .store(in: &bag)
    }
}

extension LoginViewModel {
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
    }
}
