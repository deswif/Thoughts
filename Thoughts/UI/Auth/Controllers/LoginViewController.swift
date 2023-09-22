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
    
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: LoginViewModel
    
    private let emailField: UITextField = {
        let field = AuthField()
        field.placeholder = "Email"
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = AuthField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Sign in"
        
        view.backgroundColor = .systemBackground
        
        configureFields()
        configureEmailField()
        configurePasswordField()
        configureSignInButton()
        configureActivityIndicator()
        
        listenState()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func configureFields() {
        
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
        
        emailField.delegate = self
        
        emailField.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .subscribe { self.viewModel.emailChanged(to: $0) }
            .disposed(by: disposeBag)
        
        emailField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configurePasswordField() {
        
        passwordField.delegate = self
        
        passwordField.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .subscribe { self.viewModel.passwordChanged(to: $0) }
            .disposed(by: disposeBag)
        
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
    
    private func didSignInTap() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        self.viewModel.signInPressed(with: .init(email: email, password: password))
    }
    
    private func didSignIn() {
        let feedVC = FeedViewController()
        navigationController?.setViewControllers([feedVC], animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension LoginViewController {
    
    func listenState() {
        viewModel.errorMessagesState.sink { message in
            print(message.description())
        }.store(in: &cancellables)
        
        viewModel.loadingProcessingState.sink { [self] isLoading in
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
        
        viewModel.buttonAvailableState.sink { [self] available in
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
