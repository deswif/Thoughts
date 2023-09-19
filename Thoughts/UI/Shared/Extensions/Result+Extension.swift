//
//  Future+Extension.swift
//  Thoughts
//
//  Created by Max Steshkin on 18.09.2023.
//

import Foundation
import Combine

extension Result where Success == Void {
    static func success() -> Result {
        return .success(())
    }
}
