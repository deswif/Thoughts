//
//  FeedCell.swift
//  Thoughts
//
//  Created by Max Steshkin on 19.09.2023.
//

import Foundation
import UIKit

class FeedCell: UITableViewCell {
    static let identifier = "FeedCell"
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .medium)
        
        return label
    }()
    
    private let messageBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let headerStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 10
        
        return view
    }()
    
    private let avatar: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .brown
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let userInfo: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let name: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 15)
        view.textColor = .white
        
        return view
    }()
    
    private let username: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = .white.withAlphaComponent(0.5)
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        
        contentView.addSubview(headerStack)
        headerStack.addArrangedSubview(avatar)
        headerStack.addArrangedSubview(userInfo)
        userInfo.addArrangedSubview(name)
        userInfo.addArrangedSubview(username)
        contentView.addSubview(messageBackground)
        messageBackground.addSubview(messageLabel)
        
        headerStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        avatar.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(avatar.snp.height)
        }
        
        messageBackground.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(10)
            make.bottom.lessThanOrEqualToSuperview()
            make.leading.equalTo(headerStack.snp.leading)
            make.trailing.lessThanOrEqualToSuperview()
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
    }
    
    func configure(with feed: String) {
        messageLabel.text = feed
        name.text = "Awesome"
        username.text = "@meeee"
    }
}
