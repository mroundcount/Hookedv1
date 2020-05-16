//
//  SignUpViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 2/29/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var titleTextLbl: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    //getting the users current location. Store these locally 
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    func setUpUI() {
        //Methods are in SignUpViewController file
        setUpTitleTextLbl()
        setUpAvatar()
        setUpUsernameTxt()
        setUpEmailTxt()
        setUpPasswordTxt()
        setUpSignUpBtn()
        setUpSignInBtn()
    }
    //Dismissing the view and navigate back to the welcome in scene
    //Remember the action is "show"
    @IBAction func dismissionAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func signUpBtnDidTap(_ sender: Any) {
        self.view.endEditing(true)
        self.validateFields()
        self.signUp(onSuccess: {
             (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
}
