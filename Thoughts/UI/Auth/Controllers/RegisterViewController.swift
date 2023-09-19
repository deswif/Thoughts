//
//  RegisterViewController.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import UIKit
import SwiftUI
import RxSwift
import RxCocoa
import Combine
import SnapKit

class RegisterViewController: UIViewController {
    
    private var previousKeyboardHeight: CGRect = .zero
    
    private let emailSubject = PassthroughSubject<String, Never>()
    private let passwordSubject = PassthroughSubject<String, Never>()
    private let nicknameSubject = PassthroughSubject<String, Never>()
    private let nameSubject = PassthroughSubject<String, Never>()
    
    private let registerClickSubject = PassthroughSubject<RegisterViewModel.FieldsInfo, Never>()
    
    private let disposeBag = DisposeBag()
    internal var cancellables = Set<AnyCancellable>()
    
    
    lazy private var emailField: UITextField = {
        let field = makeTextField()
        field.placeholder = "Email"
        field.keyboardType = .emailAddress
        
        return field
    }()
    
    lazy private var passwordField: UITextField = {
        let field = makeTextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        
        return field
    }()
    
    lazy private var nameField: UITextField = {
        let field = makeTextField()
        field.placeholder = "Name"
        
        return field
    }()
    
    lazy private var nicknameField: UITextField = {
        let field = makeTextField()
        field.placeholder = "Nickname"
        
        return field
    }()
    
    private let registerButton: ThoughtsButton = {
        let view = ThoughtsButton()
        view.setTitle("Create account", for: .normal)
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
        navigationItem.title = "Registration"
        
        view.backgroundColor = .systemBackground
        
        configureFieldStack()
        
        configureEmailField()
        configurePasswordField()
        configureNicknameField()
        configureNameField()
        configureRegisterButton()
        configureActivityIndicator()
        
        loadViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureFieldStack() {
        
        view.addSubview(fieldsStackView)
        
        fieldsStackView.addArrangedSubview(emailField)
        fieldsStackView.addArrangedSubview(passwordField)
        fieldsStackView.addArrangedSubview(nicknameField)
        fieldsStackView.addArrangedSubview(nameField)
        
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
    
    private func configureNicknameField() {
        
        nicknameField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { self.nicknameSubject.send($0) }.disposed(by: disposeBag)
        
        nicknameField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configureNameField() {
        
        nameField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { self.nameSubject.send($0) }.disposed(by: disposeBag)
        
        nameField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configureRegisterButton() {
        
        view.addSubview(registerButton)
        
        registerButton.rx.tap.subscribe { [weak self] _ in self?.didRegisterTap() }.disposed(by: disposeBag)
        
        registerButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.height.equalTo(52)
            make.bottom.equalTo(view.snp_bottomMargin).offset(-40)
        }
    }
    
    private func configureActivityIndicator() {
        
        view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(registerButton.snp.centerX)
            make.centerY.equalTo(registerButton.snp.centerY)
            make.height.equalTo(registerButton.snp.height)
            make.width.equalTo(activityIndicator.snp.height)
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
    
    private func didRegisterTap() {
        guard let email = emailField.text, let password = passwordField.text, let nickname = nicknameField.text, let name = nameField.text else { return }
        registerClickSubject.send(.init(email: email, password: password, username: nickname, name: name))
    }
    
    private func didSignUp() {
        let feedVC = FeedViewController()
        navigationController?.setViewControllers([feedVC], animated: true)
    }
    
    //MARK: - Preview
    
    struct Provider: PreviewProvider {
        static var previews: some View {
            UINavigationController(rootViewController: RegisterViewController()).showPreview()
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - View Model comunication

extension RegisterViewController: ViewModelDelegate {
    func createViewModel() -> RegisterViewModel {
        return RegisterViewModel(
            createUser: CreateUserUseCase(
                authRepository: DIContainer.shared.inject(type: AuthRepository.self),
                userRepository: DIContainer.shared.inject(type: UserRepository.self)
            ),
            onSignUp: didSignUp
        )
    }
    
    func events(for viewModel: RegisterViewModel) -> RegisterViewModel.Events {
        RegisterViewModel.Events(
            emailText: emailSubject.eraseToAnyPublisher(),
            passwordText: passwordSubject.eraseToAnyPublisher(),
            usernameText: nicknameSubject.eraseToAnyPublisher(),
            nameText: nameSubject.eraseToAnyPublisher(),
            registerClicks: registerClickSubject.eraseToAnyPublisher()
        )
    }
    
    func applyState(from viewModel: RegisterViewModel, state: RegisterViewModel.States) {
        
        state.errorMessages.sink { message in
            print(message.description())
        }.store(in: &cancellables)
        
        state.loadingProcessing.sink { [self] isLoading in
            emailField.isEnabled = !isLoading
            passwordField.isEnabled = !isLoading
            nicknameField.isEnabled = !isLoading
            nameField.isEnabled = !isLoading
            
            activityIndicator.isHidden = !isLoading
            registerButton.isHidden = isLoading
            
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
            
        }.store(in: &cancellables)
        
        state.buttonAvailable.sink { [self] available in
            registerButton.isEnabled = available
            UIView.animate(withDuration: 0.3) { [self] in
                registerButton.alpha = available ? 1 : 0.6
            }
        }.store(in: &cancellables)
    }
}

extension RegisterViewController {
    
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
        
        guard !keyboardFrame.equalTo(previousKeyboardHeight) else { return }
        
        previousKeyboardHeight = keyboardFrame
        
        var slideUp: CGFloat
        
        if (keyboardFrame.equalTo(.zero)) {
            slideUp = 0
        } else {
            let stackCenterY = fieldsStackView.frame.midY
            let viewCenterY = view.frame.midY
            
            let fieldsSlidedUp = stackCenterY - viewCenterY
            
            let bottomPoint = fieldsStackView.frame.maxY - fieldsSlidedUp + 30
            
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
