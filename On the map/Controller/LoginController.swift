//
//  ViewController.swift
//  On the map
//
//  Created by Eyvind on 17/5/22.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var vLoginForm: UIStackView!
    @IBOutlet weak var vLoader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfUsername.text = TestData.email
        tfPassword.text = TestData.password
        showLoader(false)
    }
    
    @IBAction func attemptLogin() {
        let username = tfUsername.text
        let password = tfPassword.text
        
        guard let username = username else {
            return
        }
        
        guard let password = password else {
            return
        }
        
        showLoader(true)
        RestClient.login(username: username, password: password, completion: self.onLoginResult)
    }
    
    func onLoginResult(success: Bool, errorMessage: String?, error: Error?) {
        showLoader(false)
        if success {
            performSegue(withIdentifier: "toTabStoryboard", sender: nil)
        } else {
            let alertVC = UIAlertController(title: "Login Failed", message: errorMessage ?? "Unkwon error", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            show(alertVC, sender: nil)
        }
    }

    func showLoader(_ isLoading: Bool){
        vLoginForm.isHidden = isLoading
        vLoader.isHidden = !isLoading
        
        if isLoading {
            vLoader.startAnimating()
        } else {
            vLoader.stopAnimating()
        }
    }
    
    @IBAction func signUp(){
        if let url = URL(string: "https://auth.udacity.com/sign-up") {
            UIApplication.shared.open(url)
        }
    }
}

