//
//  ViewController.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import UIKit
import SnapKit
import SwiftUI

class AuthViewController: UIViewController {
    
    var coordinator: AuthCoordinator?
    
    let logo: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "lasso.and.sparkles"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .label
        
        return image
    }()
    
    let signInButton: ThoughtsButton = {
        let view = ThoughtsButton()
        view.setTitle("Sign in", for: .normal)
        view.setTitleColor(.systemBackground, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .label
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    let registerButton: ThoughtsButton = {
        let view = ThoughtsButton()
        view.setTitle("Register", for: .normal)
        view.setTitleColor(.systemBackground, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .label
        view.layer.cornerRadius = 12
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureImage()
        configureSignInButton()
        configureRegisterButton()
    }
    
    private func configureImage() {
        view.addSubview(logo)
        
        logo.snp.makeConstraints { make in
            make.width.equalTo(self.view.bounds.width * 0.7)
            make.height.equalTo(logo.snp.width)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    private func configureSignInButton() {
        view.addSubview(signInButton)
        
        signInButton.addTarget(self, action: #selector(didSignInTap), for: .touchUpInside)
        
        signInButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.bottom.equalTo(self.view.snp_bottomMargin).offset(-40)
            make.height.equalTo(52)
        }
    }
    
    private func configureRegisterButton() {
        view.addSubview(registerButton)
        
        registerButton.addTarget(self, action: #selector(didRegisterTap), for: .touchUpInside)
        
        registerButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.bottom.equalTo(self.signInButton.snp.top).offset(-20)
            make.height.equalTo(52)
        }
    }
    
    
    @objc func didSignInTap() {
        coordinator?.signIn()
    }
    
    @objc func didRegisterTap() {
        coordinator?.registerAccount()
    }
    
    
    //MARK: - Preview
    
    struct Preview: PreviewProvider {
        static var previews: some View {
            UINavigationController(rootViewController: AuthViewController()).showPreview()
        }
    }
}

