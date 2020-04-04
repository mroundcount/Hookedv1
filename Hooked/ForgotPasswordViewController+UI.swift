//
//  ForgotPasswordViewController+UI.swift
//  Hooked
//
//  Created by Michael Roundcount on 2/29/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit

extension ForgotPasswordViewController {

    func setUpEmailTxt() {
    //copy over from SignUpViewController+UI
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        emailContainerView.layer.cornerRadius = 3
        emailContainerView.clipsToBounds = true
        
        emailTxt.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        emailTxt.attributedPlaceholder = placeholderAttr
        emailTxt.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)

    }
    func setUpResetBtn() {
        resetBtn.setTitle("RESET MY PASSWORD", for: UIControl.State.normal)
        resetBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        resetBtn.backgroundColor = UIColor.black
        resetBtn.layer.cornerRadius = 5
        resetBtn.clipsToBounds = true
        resetBtn.setTitleColor(.white, for: UIControl.State.normal)
    }

}
