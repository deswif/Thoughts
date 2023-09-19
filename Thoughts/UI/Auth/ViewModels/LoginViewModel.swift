//
//  LoginViewModel.swift
//  Thoughts
//
//  Created by Max Steshkin on 19.09.2023.
//

import Foundation
import Combine

class LoginViewModel: ViewModel {
    
    private let signInUser: SignInUserUseCase
    
    private let errorMessagesSubject = PassthroughSubject<ErrorMessage, Never>()
    private let buttonAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    private let loadingProcessing = CurrentValueSubject<Bool, Never>(false)
    
    private var onSignIn: () -> Void
    
    private var bag = Set<AnyCancellable>()
    
    init(signInUserUseCase: SignInUserUseCase, onSignIn: @escaping () -> Void) {
        self.signInUser = signInUserUseCase
        self.onSignIn = onSignIn
    }
    
    func transform(events: Events) -> States {
        bag.forEach { $0.cancel() }
        bag.removeAll()
        
        events.emailText.combineLatest(events.passwordText) { email, password in
            return FieldValidators.valid(email: email) &&
            FieldValidators.valid(password: password)
        }
        .removeDuplicates()
        .sink { self.buttonAvailableSubject.send($0) }
        .store(in: &bag)
        
        events.signInClicks.filter { info in
            FieldValidators.valid(email: info.email) &&
            FieldValidators.valid(password: info.password)
        }.sink { [self] info in
            loadingProcessing.send(true)
            signInUser.call(with: .init(email: info.email, password: info.password))
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
                    self?.onSignIn()
                }
                .store(in: &bag)
        }.store(in: &bag)
        
        return States(
            errorMessages: errorMessagesSubject.eraseToAnyPublisher(),
            buttonAvailable: buttonAvailableSubject.eraseToAnyPublisher(),
            loadingProcessing: loadingProcessing.eraseToAnyPublisher()
        )
    }
}

extension LoginViewModel {
    struct States {
        let errorMessages: AnyPublisher<ErrorMessage, Never>
        let buttonAvailable: AnyPublisher<Bool, Never>
        let loadingProcessing: AnyPublisher<Bool, Never>
    }
    
    struct Events {
        let emailText: AnyPublisher<String, Never>
        let passwordText: AnyPublisher<String, Never>
        let signInClicks: AnyPublisher<FieldsInfo, Never>
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
