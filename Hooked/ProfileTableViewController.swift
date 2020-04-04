//
//  ProfileTableViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/21/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    //reconnect later
    //header name give in selection atributes
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeData()
        setupView()
        setUpAvatar()
    }
    
    func setupView() {
        setUpAvatar()
        //dismiss they keyboard with a tap gesture
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setUpAvatar() {
        //making the UIImage circular note: height and width is 80
        avatar.layer.cornerRadius = 40
        avatar.clipsToBounds = true
        //adding actions to respond to tap gesture
        avatar.isUserInteractionEnabled = true
        //use self becauase it it is on the signUpViewController itseld
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGesture)
    }
    
    //allowing users to select images from the library
    @objc func presentPicker() {
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        //users can edit the selected photo
        picker.allowsEditing = true
        //enable methods in the UIImage picker delegate
        picker.delegate = self
        //Making the image fill the entire UIIMage space
        avatar.contentMode = . scaleAspectFill
        self.present(picker, animated: true, completion: nil)
    }
    
    func observeData() {
        //fetching current user data
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            self.statusTextField.text = user.status
            self.avatar.loadImage(user.profileImageUrl)
            //adding age and genedner to the user model. These are editable and push to the database
            if let age = user.age {
                self.ageTextField.text = "\(age)"
            } else {
                self.ageTextField.placeholder = "Optional"
            }
            //highlighting the corresponding segement selection
            if let isMale = user.isMale {
                self.genderSegment.selectedSegmentIndex = (isMale == true) ? 0 : 1
            }
        }
    }
    
    
    @IBAction func logoutBtnDidTap(_ sender: Any) {
        Api.User.logOut()
    }
    
    @IBAction func saveBtnDidTap(_ sender: Any) {
        ProgressHUD.show("Loading...")
        
        //saving the updated text fields. We're going to be doing it the whole dictonary at a time
        var dict = Dictionary<String, Any>()
        
        if let username = usernameTextField.text, !username.isEmpty {
            dict["username"] = username
        }
        if let email = emailTextField.text, !email.isEmpty {
            dict["email"] = email
        }
        if let status = statusTextField.text, !status.isEmpty {
            dict["status"] = status
        }
        
        if genderSegment.selectedSegmentIndex == 0 {
            dict["isMale"] = true
        }
        if genderSegment.selectedSegmentIndex == 1 {
            dict["isMale"] = false
        }
        if let age = ageTextField.text, !age.isEmpty {
            dict["age"] = Int(age)
        }
        
        //Calling a method in user to save the dictonary above to the database
        Api.User.saveUserProfile(dict: dict, onSuccess: {
            //making sure the image variable is not nil. We need to get and process in it to upload to the database
            if let img = self.image {
                //call the methos in the storageServices to actually save the updated photo to the datebase
                StorageService.savePhotoProfile(image: img, uid: Api.User.currentUserId, onSuccess: {
                    ProgressHUD.showSuccess()
                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
}


//Method for the immage piker delegate.
extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //updating the avatar any time a user picks up an image.
    //display the photo on the UIIMage view. Use editedImage so if the photo is edited this info will return on the edited photo.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            image = imageSelected
            avatar.image = imageSelected
        }
        //If the user does not update their avatar. It will return to the default image
        if let imageOrigional = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            image = imageOrigional
            avatar.image = imageOrigional
        }
        picker.dismiss(animated: true, completion: nil)
    }
        
}

