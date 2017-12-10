//
//  SignInVC.swift
//  Uber App For Driver
//
//  Created by Shreyash Kawalkar on 07/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    private let Driver_Segue = "driverVC"

    @IBAction func signUp(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProviders.instance.signUp(email: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                self.alertTheUser(title: "Problem With Authentication", message: message!)
                }
            else {
                UberHandler.instance.driver = self.emailTextField.text!
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                
                self.performSegue(withIdentifier: self.Driver_Segue, sender: nil)                }
            })
        }
        else{
        alertTheUser(title: "Email and Password are required", message: "Please enter email and password in the field")}
        
    }
    
    @IBAction func logIn(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProviders.instance.signIn(email: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                if message != nil {
                self.alertTheUser(title: "Problem With Authentication", message: message!)
                }
                else {
                UberHandler.instance.driver = self.emailTextField.text!
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
               self.performSegue(withIdentifier: self.Driver_Segue, sender: nil)
                }
            })
        }else{
            alertTheUser(title: "Email and Password are required", message: "Please enter email and password in the field")}


    }
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title : "Ok", style: .default, handler: nil)
       alert.addAction(ok)
       present(alert, animated: true, completion: nil)
    }

}
