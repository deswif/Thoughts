//
//  DIContainer.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation

final class DIContainer {

  static let shared = DIContainer()

  private init() {}

  var services: [String: Any] = [:]

    func register<Service>(type: Service.Type, component service: Any) {
      services["\(type)"] = service
  }

  func inject<Service>(type: Service.Type) -> Service {
    return services["\(type)"] as! Service
  }
    
    func maybeInject<Service>(type: Service.Type) -> Service? {
      return services["\(type)"] as? Service
    }
}
