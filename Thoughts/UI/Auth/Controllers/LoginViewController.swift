//
//  LoginViewController.swift
//  Thoughts
//
//  Created by Max Steshkin on 15.09.2023.
//

import UIKit
import SwiftUI
import Combine
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    private var previousKeyboardHeight: CGRect = .zero
    
    private let emailSubject = PassthroughSubject<String, Never>()
    private let passwordSubject = PassthroughSubject<String, Never>()
    
    private let signInClickSubject = PassthroughSubject<LoginViewModel.FieldsInfo, Never>()
    
    private let disposeBag = DisposeBag()
    internal var cancellables = Set<AnyCancellable>()
    
    lazy private var emailField: UITextField = {
        let field = makeTextField()
        field.placeholder = "Email"
        
        return field
    }()
    
    lazy private var passwordField: UITextField = {
        let field = makeTextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let signInButton: ThoughtsButton = {
        let view = ThoughtsButton()
        view.setTitle("Sign in", for: .normal)
        view.setTitleColor(.systemBackground, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .label
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    private let fieldsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Sign in"
        
        view.backgroundColor = .systemBackground
        
        layoutFields()
        
        configureEmailField()
        configurePasswordField()
        configureSignInButton()
        configureActivityIndicator()
        
        loadViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func layoutFields() {
        
        view.addSubview(fieldsStackView)
        
        fieldsStackView.addArrangedSubview(emailField)
        fieldsStackView.addArrangedSubview(passwordField)
        
        fieldsStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureEmailField() {
        
        emailField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { self.emailSubject.send($0) }.disposed(by: disposeBag)
        
        emailField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configurePasswordField() {
        
        passwordField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { self.passwordSubject.send($0) }.disposed(by: disposeBag)
        
        passwordField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configureSignInButton() {
        
        view.addSubview(signInButton)
        
        signInButton.rx.tap.subscribe { [weak self] _ in self?.didSignInTap() }.disposed(by: disposeBag)
        
        signInButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.height.equalTo(52)
            make.bottom.equalTo(view.snp_bottomMargin).offset(-40)
        }
    }
    
    private func configureActivityIndicator() {
        
        view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(signInButton.snp.centerX)
            make.centerY.equalTo(signInButton.snp.centerY)
            make.height.equalTo(signInButton.snp.height)
            make.width.equalTo(signInButton.snp.height)
        }
    }
    
    private func makeTextField() -> UITextField {
        let field = AuthField()
        field.returnKeyType = .done
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        
        return field
    }
    
    private func didSignInTap() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        signInClickSubject.send(.init(email: email, password: password))
    }
    
    private func didSignIn() {
        let feedVC = FeedViewController()
        navigationController?.setViewControllers([feedVC], animated: true)
    }
    
    
    //MARK: - Preview
    
    struct Provider: PreviewProvider {
        static var previews: some View {
            UINavigationController(rootViewController: LoginViewController()).showPreview()
        }
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension LoginViewController: ViewModelDelegate {
    
    func createViewModel() -> LoginViewModel {
        LoginViewModel(
            signInUserUseCase: SignInUserUseCase(
                authRepository: DIContainer.shared.inject(type: AuthRepository.self)
            ),
            onSignIn: didSignIn
        )
    }
    
    func events(for viewModel: LoginViewModel) -> LoginViewModel.Events {
        LoginViewModel.Events(
            emailText: emailSubject.eraseToAnyPublisher(),
            passwordText: passwordSubject.eraseToAnyPublisher(),
            signInClicks: signInClickSubject.eraseToAnyPublisher()
        )
    }
    
    func applyState(from viewModel: LoginViewModel, state: LoginViewModel.States) {
        state.errorMessages.sink { message in
            print(message.description())
        }.store(in: &cancellables)
        
        state.loadingProcessing.sink { [self] isLoading in
            emailField.isEnabled = !isLoading
            passwordField.isEnabled = !isLoading
            
            activityIndicator.isHidden = !isLoading
            signInButton.isHidden = isLoading
            
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
            
        }.store(in: &cancellables)
        
        state.buttonAvailable.sink { [self] available in
            print(available)
            signInButton.isEnabled = available
            UIView.animate(withDuration: 0.3) { [self] in
                signInButton.alpha = available ? 1 : 0.6
            }
        }.store(in: &cancellables)
    }
}

extension LoginViewController {
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        
        guard
            let userInfo = notification.userInfo,
            let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        else { return }
        
        let frame = frameValue.cgRectValue
        
        let options = UIView.AnimationOptions(rawValue: curve.uintValue)
        
        setFieldsFor(keyboardFrame: frame, duration: duration.doubleValue, options: options)
        
    }
    
    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        else { return }
        
        let options = UIView.AnimationOptions(rawValue: curve.uintValue)
        
        setFieldsFor(keyboardFrame: CGRect.zero, duration: duration.doubleValue, options: options)
    }
    
    private func setFieldsFor(keyboardFrame: CGRect, duration: TimeInterval, options: UIView.AnimationOptions) {
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            guard !keyboardFrame.equalTo(strongSelf.previousKeyboardHeight) else { return }
            
            strongSelf.previousKeyboardHeight = keyboardFrame
            
            print(keyboardFrame)
            
            var slideUp: CGFloat
            
            if (keyboardFrame.equalTo(.zero)) {
                slideUp = 0
            } else {
                let stackCenterY = strongSelf.fieldsStackView.frame.midY
                let viewCenterY = strongSelf.view.frame.midY
                
                let fieldsSlidedUp = stackCenterY - viewCenterY
                
                let bottomPoint = strongSelf.fieldsStackView.frame.maxY - fieldsSlidedUp + 120
                
                if (bottomPoint < keyboardFrame.origin.y) { return }
                
                slideUp = keyboardFrame.origin.y - bottomPoint
            }
            
            let durationWrapper = duration == 0 ? 0.2 : duration
            
            UIView.animate(withDuration: durationWrapper, delay: 0, options: options) { [weak self] in
                
                self?.fieldsStackView.snp.updateConstraints { make in
                    make.centerY.equalToSuperview().offset(slideUp)
                }
                
                self?.view.layoutIfNeeded()
            }
        }
    }
}
