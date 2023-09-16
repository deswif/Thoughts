//
//  Preview+Extension.swift
//  Thoughts
//
//  Created by Max Steshkin on 14.09.2023.
//

import Foundation
import UIKit
import SwiftUI

extension UIViewController {
    
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController (context: Context) -> some UIViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
    
    func showPreview() -> some View {
        Preview(viewController: self).edgesIgnoringSafeArea(.all)
    }
}

extension UIView {
    
    private struct Preview: UIViewRepresentable {
        let view: UIView
        
        func makeUIView (context: Context) -> some UIView {
            view
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            
        }
    }
    
    func showPreview() -> some View {
        Preview(view: self).edgesIgnoringSafeArea(.all)
    }
}
