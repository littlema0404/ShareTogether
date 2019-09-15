//
//  LoginViewController.swift
//  ShareTogether
//
//  Created by littlema on 2019/9/8.
//  Copyright © 2019 littema. All rights reserved.
//

import UIKit

class LoginViewController: STBaseViewController {
    
    override var isHideNavigationBar: Bool { return true }
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var googleLoginButton: UIButton!

    @IBOutlet weak var facebookLoginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func clickLoginButton(_ sender: UIButton) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            print("請輸入完整資訊")
        } else {
            
            AuthManager.shared.emailSignIn(email: emailTextField.text!,
                                            password: passwordTextField.text!) { [weak self] result in
                
                if result != nil {
                    
                } else {
                    print(result ?? "error")
                }
            }
            
        }
        
    }
    
    func checkUserGroup() {
        
        FirestoreManager.shared.getUserInfo { [weak self] result in
            switch result {
                
            case .success(let userInfo):
                print(userInfo)
                if UserInfoManager.shaered.currentGroup != nil {
                    self?.goMainVC()
                } else {
                    
                    if let groups = userInfo.groups, !groups.isEmpty {
                        for group in groups {
                            group.id == "r2faZu22KX4ZbG7Fv86A" ? UserInfoManager.shaered.setCurrentGroup(group) : nil
                        }

                        self?.goMainVC()
                    } else {
                        self?.goMainVC()
                    }
                    
                }
                
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
    
    func goMainVC() {
        
        if presentingViewController != nil {
            let presentingVC = presentingViewController
            dismiss(animated: true) {
                presentingVC?.dismiss(animated: true, completion: nil)
            }
        } else {
            let nextVC = UIStoryboard.main.instantiateInitialViewController()!
            present(nextVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func clickOAuthLogin(_ sender: UIButton) {
        
        if sender.tag == 1 {
            AuthManager.shared.googleSignIn(viewContorller: self) { [weak self] result in
                switch result {
                case true:
                    self?.checkUserGroup()
                case false:
                    print("error")
                }
            }
        } else if sender.tag == 2 {
            AuthManager.shared.facebookSignIn(viewContorller: self) { [weak self] result in
                switch result {
                case true:
                    self?.checkUserGroup()
                case false:
                    print("error")
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBase()
    }
    
    func setupBase() {
        emailTextField.addLeftSpace()
        emailTextField.textColor = .STDarkGray
        passwordTextField.addLeftSpace()
        passwordTextField.textColor = .STDarkGray
        
        loginButton.backgroundColor = .STTintColor
        loginButton.setTitleColor(.white, for: .normal)
        
        googleLoginButton.setImage(.getIcon(code: "logo-google", color: .STTintColor, size: 20), for: .normal)
        googleLoginButton.layer.borderColor = UIColor.STTintColor.cgColor
        googleLoginButton.layer.borderWidth = 1.0
        
        facebookLoginButton.setImage(.getIcon(code: "logo-facebook", color: .STTintColor, size: 20), for: .normal)
        facebookLoginButton.layer.borderColor = UIColor.STTintColor.cgColor
        facebookLoginButton.layer.borderWidth = 1.0
        
        signUpButton.setTitleColor(.STDarkGray, for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        emailTextField.layer.cornerRadius = emailTextField.frame.height / 4
        passwordTextField.layer.cornerRadius = passwordTextField.frame.height / 4
        
        loginButton.layer.cornerRadius = loginButton.frame.height / 4
        googleLoginButton.layer.cornerRadius = googleLoginButton.frame.height / 4
        facebookLoginButton.layer.cornerRadius = facebookLoginButton.frame.height / 4
        signUpButton.layer.cornerRadius = signUpButton.frame.height / 4

    }
    
    deinit {
        print("LoginViewController - deinit")
    }

}