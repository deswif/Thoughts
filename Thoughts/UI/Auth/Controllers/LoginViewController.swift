//
//  LoginViewController.swift
//  Thoughts
//
//  Created by Max Steshkin on 15.09.2023.
//

import UIKit
import SwiftUI

class LoginViewController: UIViewController {
    
    private var previousKeyboardHeight: CGRect = .zero
    
    lazy private var nicknameField: UITextField = {
        let field = makeTextField()
        field.placeholder = "Nickname"
        
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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Sign in"
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(fieldsStackView)
        
        fieldsStackView.addArrangedSubview(nicknameField)
        fieldsStackView.addArrangedSubview(passwordField)
        
        view.addSubview(signInButton)
        
        nicknameField.delegate = self
        passwordField.delegate = self
        
        signInButton.addTarget(self, action: #selector(didSignInTap), for: .touchUpInside)
        
        configureNicknameField()
        configurePasswordField()
        configureSignInButton()
        
        layoutFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func layoutFields() {
        fieldsStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configureNicknameField() {
        nicknameField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configurePasswordField() {
        passwordField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    private func configureSignInButton() {
        signInButton.snp.makeConstraints { make in
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
        
        return field
    }
    
    @objc private func didSignInTap() {
        print(nicknameField.text, passwordField.text)
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
