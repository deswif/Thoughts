//
//  AuthField.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import UIKit

class AuthField: UITextField {
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .systemGray4
        layer.cornerRadius = 10
        returnKeyType = .done
        autocorrectionType = .no
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }

        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }

        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
}
