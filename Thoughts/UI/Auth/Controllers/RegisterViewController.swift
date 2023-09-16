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

class RegisterViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var cancellables = Set<AnyCancellable>()
    
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
        
        emailField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { EventSubjects.emailSubject.send($0) }.disposed(by: disposeBag)
        
        emailField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configurePasswordField() {
        
        passwordField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { EventSubjects.passwordSubject.send($0) }.disposed(by: disposeBag)
        
        passwordField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configureNicknameField() {
        
        nicknameField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { EventSubjects.nicknameSubject.send($0) }.disposed(by: disposeBag)
        
        nicknameField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configureNameField() {
        
        nameField.rx.text.filter { $0 != nil }.map { $0! }.subscribe { EventSubjects.nameSubject.send($0) }.disposed(by: disposeBag)
        
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
    
    private func makeTextField() -> UITextField {
        let field = AuthField()
        field.returnKeyType = .done
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        
        return field
    }
    
    @objc private func didRegisterTap() {
        print(emailField.text, passwordField.text, nicknameField.text, nameField.text)
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
        return RegisterViewModel()
    }
    
    func events(for viewModel: RegisterViewModel) -> RegisterViewModel.Events {
        RegisterViewModel.Events(
            emailText: EventSubjects.emailSubject.eraseToAnyPublisher(),
            passwordText: EventSubjects.passwordSubject.eraseToAnyPublisher(),
            nicknameText: EventSubjects.nicknameSubject.eraseToAnyPublisher(),
            nameText: EventSubjects.nameSubject.eraseToAnyPublisher(),
            registerClicks: PassthroughSubject<RegisterViewModel.FieldsInfo, Never>().eraseToAnyPublisher()
        )
    }
    
    func applyState(from viewModel: RegisterViewModel, state: RegisterViewModel.States) {
        
        state.errorMessages.sink { message in
            print(message.description())
        }.store(in: &cancellables)

        state.loadingProcessing.sink { isLoading in
            print("loading")
        }.store(in: &cancellables)
        
        state.buttonAvailable.sink { available in
            print(available)
        }.store(in: &cancellables)
    }
    
    private struct EventSubjects {
        static let emailSubject = PassthroughSubject<String, Never>()
        static let passwordSubject = PassthroughSubject<String, Never>()
        static let nicknameSubject = PassthroughSubject<String, Never>()
        static let nameSubject = PassthroughSubject<String, Never>()
    }
}

extension RegisterViewController {
    
    private struct KeyboardHolder {
        static var previousKeyboardHeight: CGRect = .zero
    }
    
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
        
        guard !keyboardFrame.equalTo(KeyboardHolder.previousKeyboardHeight) else { return }
        
        KeyboardHolder.previousKeyboardHeight = keyboardFrame
        
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
