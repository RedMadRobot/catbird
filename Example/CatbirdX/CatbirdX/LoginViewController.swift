//
//  ViewController.swift
//  CatbirdX
//
//  Created by Alexander Ignatev on 27/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private let authService = AuthService()

    
    @IBAction private func done() {
        guard
            let login = loginTextField.text,
            let password = passwordTextField.text
        else {
            return
        }
        authService.login(with: login, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.performSegue(withIdentifier: "ShowMain", sender: nil)
            case .failure:
                let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self?.present(alert, animated: false)
            }
        }
    }
    
}

