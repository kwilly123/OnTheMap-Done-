//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Kyle Wilson on 2020-02-10.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
        activityIndicator.isHidden = true
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: LOGIN TAPPED
    
    @IBAction func loginTapped(_ sender: Any) {
        fieldsChecker()
        UdacityClient.login(self.emailTextField.text!, self.passwordTextField.text!) { (successful, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.errorAlert("Invalid Access", error?.localizedDescription)
                    self.setLoggingIn(false)
                }
            }
            
            if successful {
                print("success")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "presentMap", sender: sender)
                    self.setLoggingIn(false)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorAlert("Invalid Access", "Invalid Email or Password")
                    self.setLoggingIn(false)
                }
            }
        }
    }
    
    //MARK: SIGN UP TAPPED
    
    @IBAction func signUpTapped(_ sender: Any) {
        let url = UdacityClient.Endpoints.signUp.url
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    //MARK: CHECK FIELDS
    
    func fieldsChecker(){
        if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!  {
            DispatchQueue.main.async {
                self.errorAlert("Credentials were not filled in", "Please fill both email and password")
            }
        } else {
            DispatchQueue.main.async {
                self.setLoggingIn(true)
            }
        }
    }
    
    //MARK: UISTATE FOR LOGGING IN
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            print("loggin in")
        } else {
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
    }
    
    //MARK: ERROR ALERT FUNCTION
    
    func errorAlert(_ title: String?, _ message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
    }
}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

