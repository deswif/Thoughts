//
//  DIContainer+Register.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation


extension DIContainer {
    func registration() {

        
       // Auth
        register(type: AuthRepository.self, component: AuthRepositoryImpl())
        
        register(type: UserRemoteResource.self, component: UserRemoteResourceImpl())
        register(type: UserRepository.self, component: UserRepositoryImpl())
    }
}
