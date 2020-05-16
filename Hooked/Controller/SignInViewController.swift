//
//  SignInViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 2/29/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import ProgressHUD

class SignInViewController: UIViewController {

    
    @IBOutlet weak var titleTextLbl: UILabel!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    func setUpUI() {
        setUpTitleTextLbl()
        setUpEmailTxt()
        setUpPasswordTxt()
        setUpSignUpBtn()
        setUpSignInBtn()
    }
    
    //Dismissing the view and navigate back to the welcome in scene
    //Remember the action is "show"
    @IBAction func dismissionAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInButtonDidTapped(_ sender: Any) {
        //Call the sign in method afte validation is complete and dismiss the keyboard
        self.view.endEditing(true)
        self.validateFields()
        self.signIn(onSuccess: {
            //switch view
            (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
}
