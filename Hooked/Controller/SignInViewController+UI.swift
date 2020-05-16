//
//  SignInViewController+UI.swift
//  Hooked
//
//  Created by Michael Roundcount on 2/29/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import ProgressHUD

extension SignInViewController {

    func setUpTitleTextLbl() {
        let title = "Sign In"
        //copy over from ViewController+UI
        let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        
        titleTextLbl.attributedText = attributedText
    }


    func setUpEmailTxt() {
        //copy over from signUpViewController+UI
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        emailContainerView.layer.cornerRadius = 3
        emailContainerView.clipsToBounds = true
        emailTxt.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        emailTxt.attributedPlaceholder = placeholderAttr
        emailTxt.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
        
    }
    
    func setUpPasswordTxt() {
        passwordContainerView.layer.borderWidth = 1
        passwordContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        passwordContainerView.layer.cornerRadius = 3
        passwordContainerView.clipsToBounds = true
        
        passwordTxt.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        passwordTxt.attributedPlaceholder = placeholderAttr
        passwordTxt.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    
    func setUpSignInBtn() {
        signInBtn.setTitle("Sign In", for: UIControl.State.normal)
        signInBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signInBtn.backgroundColor = UIColor.black
        signInBtn.layer.cornerRadius = 5
        signInBtn.clipsToBounds = true
        signInBtn.setTitleColor(.white, for: UIControl.State.normal)
    }
    
    func setUpSignUpBtn() {
        //copy attributed string key values from SignUpViewController+UI
        let attributedText = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
        
        let attributedSubText = NSMutableAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.black])
        
        attributedText.append(attributedSubText)
        signUpBtn.setAttributedTitle(attributedText, for: UIControl.State.normal)
    }
    
    func validateFields() {
        //copied from signUpViewController+UI
        guard let email = self.emailTxt.text, !email.isEmpty else {
            ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            return
        }
        guard let password = self.passwordTxt.text, !password.isEmpty else {
            ProgressHUD.showError(ERROR_EMPTY_PASSWORD)
            return
        }
    }
    //copied from SignUp
    func signIn(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        ProgressHUD.show("Loading...")
        Api.User.signIn(email: self.emailTxt.text!, password: passwordTxt.text!, onSuccess: {
            ProgressHUD.dismiss()
            onSuccess()
        }) { (errorMesssage) in
            onError(errorMesssage)
        }
    }
}
