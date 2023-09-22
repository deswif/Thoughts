//
//  Coordinator.swift
//  Thoughts
//
//  Created by Max Steshkin on 22.09.2023.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    
    init(navigationController: UINavigationController)
    
    func start()
}
