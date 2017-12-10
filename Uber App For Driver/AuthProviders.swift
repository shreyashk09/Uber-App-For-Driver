//
//  AuthProvider.swift
//  Uber App For Driver
//
//  Created by Shreyash Kawalkar on 08/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import Foundation
import Firebase

typealias LoginHandler = (_ msg: String?) -> Void;
struct LoginErrorCode{
    static let INVALID_EMAIL = "Invalid email address, please enter vaid email address"
    static let WRONG_PASSWORD = "Wrong password please enter valid password"
    static let USER_NOT_FOUND = "User not found, please register to login"
    static let EMAIL_ALREADY_IN_USE = "Email already in use, please use another email to register"
    static let WEAK_PASSWORD = "Too short, Password should be atleat 6 character long"
    static let PROBLEM_CONNECTING = "Error in connection"
}

class AuthProviders{
private static let _inst=AuthProviders()
    static var instance : AuthProviders{return _inst
    }
    
    func signUp(email: String, password: String, loginHandler: LoginHandler?){
        if email != "" && password != "" {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, Error) in
                if Error != nil {
                    self.handleErrors(err: Error! as NSError, loginHandler: loginHandler!)
                }
                else{
                    print("created user")
                    loginHandler!(nil)
                    if user?.uid != nil {
                        DBProvider.instance.saveUser(id: user!.uid, email: email, password: password)
                    self.signIn(email: email, password: password, loginHandler: loginHandler)
                    }
                }
            })
    }
    }
    func signIn(email: String, password: String, loginHandler: LoginHandler?){
        if email != "" && password != "" {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, Error) in
        if Error != nil { self.handleErrors(err: Error! as NSError, loginHandler: loginHandler!) }
        else {print("logged in")
            loginHandler!(nil)}
    })
    }
    }
    
    func logOut() -> Bool{
        if Auth.auth().currentUser != nil{
            do{
            try Auth.auth().signOut()
                return true
            }
            catch{
        return false
            }}
        else{
            return true
        }
    }
    private func handleErrors(err: NSError,loginHandler: LoginHandler){
        if let errCode = AuthErrorCode(rawValue: err.code){
            switch errCode{
            case .wrongPassword:
                loginHandler(LoginErrorCode.WRONG_PASSWORD)
                break;
            case .invalidEmail:
                loginHandler(LoginErrorCode.INVALID_EMAIL)
                break;
            case .userNotFound:
                loginHandler(LoginErrorCode.USER_NOT_FOUND)
                break;
            case .emailAlreadyInUse:
                loginHandler(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break;
            case .weakPassword:
                loginHandler(LoginErrorCode.WEAK_PASSWORD)
                break
            default:
                loginHandler(LoginErrorCode.PROBLEM_CONNECTING)
                break;
            }
        }
    }
}
