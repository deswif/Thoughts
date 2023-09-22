//
//  FeedViewController.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import UIKit
import SwiftUI
import FirebaseAuth

class FeedViewController: UIViewController {
    
    let feeds: [String] = .init(repeating: "", count: 100).map { _ in ["today is a briliant weather👍", "whait!\nwho was stiv jobs?\ndid he create the iphone?", "pisi popki kakashecki", "nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama nyama "][Int.random(in: 0..<4)] }
    
    private let feedsTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 50
        view.alwaysBounceVertical = true
        view.allowsSelection = false
        view.separatorStyle = .none
        view.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 100, right: 0)
        view.showsVerticalScrollIndicator = false
        view.register(FeedCell.self, forCellReuseIdentifier: FeedCell.identifier)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureNavBar()
        configureCollectionView()
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Feed"
        
        let profile = UIBarButtonItem(image: UIImage(systemName: "person.circle.fill"), style: .plain, target: self, action: #selector(didProfilePressed))
        
        navigationItem.rightBarButtonItems = [profile]
    }
    
    private func configureCollectionView() {
        
        feedsTableView.delegate = self
        feedsTableView.dataSource = self
        
        view.addSubview(feedsTableView)
        feedsTableView.frame = view.bounds
    }
    
    @objc func didProfilePressed() {
        do {
           try Auth.auth().signOut()
        } catch (let e) {
            print(e)
        }
    }
    
    struct Provider: PreviewProvider {
        static var previews: some View {
            UINavigationController(rootViewController: FeedViewController()).showPreview()
        }
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        feeds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.identifier, for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        let feed = feeds[indexPath.section]
        cell.configure(with: feed)
        return cell
    }
}
