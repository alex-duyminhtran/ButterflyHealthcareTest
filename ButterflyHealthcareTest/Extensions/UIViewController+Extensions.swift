//
//  UIViewController+Extensions.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

import Foundation
import UIKit

/// Provide helper metthos
extension UIViewController {
    
    func showErrorSnackbar(message: String) {
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        
        label.alpha = 0
        label.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: 50)
        view.addSubview(label)
        
        UIView.animate(withDuration: 0.3) {
            label.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }

        }
    }
    
    func showErrorAlert(message: String) {
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
