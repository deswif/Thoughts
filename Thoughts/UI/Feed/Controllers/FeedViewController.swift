//
//  FeedViewController.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import UIKit
import SwiftUI

class FeedViewController: UIViewController {
    
    private let feedsCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureTableView()
    }
    
    private func configureTableView() {
        
        feedsCollectionView.delegate = self
        feedsCollectionView.dataSource = self
        
        view.addSubview(feedsCollectionView)
        
        feedsCollectionView.frame = view.bounds
    }
    
    struct Provider: PreviewProvider {
        static var previews: some View {
            UINavigationController(rootViewController: FeedViewController()).showPreview()
        }
    }
}

extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .cyan
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - 17.5 - 17.5, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let top = section == 0 ? 0 : 17.5
        let bottom = section == collectionView.numberOfSections - 1 ? 40 : 17.5
        
        return UIEdgeInsets(top: CGFloat(top), left: 17.5, bottom: CGFloat(bottom), right: 17.5)
    }
}

class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
