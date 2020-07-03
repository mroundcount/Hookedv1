//
//  UserApi.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/6/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseStorage
import ProgressHUD

//All methods of the user business services (create user, sign in, etc.)
class UserApi {
    
    //returns the user ID of the user logged in
    var currentUserId: String {
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    
    
    //signs in based on an email address and password. I would like to change this to username, but this seemed to be built into the Auth
    func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        //This is specifically for email and password. There are other built in tools in Auth
        Auth.auth().signIn(withEmail: email, password: password) {
            (authData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            //print(authData?.user.uid)
            onSuccess()
        }
    }

    
    //function with the input parameters we need to pass in. We need all this info from the signUpView controller and now we need to pass all the parameters into this method
    func signUp(withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        //firebase authentication. Create user methed creates an account. Result and error are object receieved from firebase after the creation process.
        Auth.auth().createUser(withEmail: email, password: password) {
            (AuthDataResult, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            //Results returns all users info
            if let authData = AuthDataResult {
                //dictionary to hold all the user data
                let dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email,
                    USERNAME: username,
                    PROFILE_IMAGE_URL: "",
                    STATUS: "Welcome to Hooked"
                ]
                //Convert the UIImage to jpeg data format.
                guard let imageSelected = image else {
                    ProgressHUD.showError(ERROR_EMPTY_PHOTO)
                    return
                }
                //firebase format. We need to use jpeg format. We will use the compression ratio of 0.4 so it is lightweight.
                guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                    return
                }
                
                let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                //upload the image data to Firebase.
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                //Use the StorageService API and pass in the parameters
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfile, dict: dict, onSuccess: {
                    onSuccess()
                }, onError: { (errorMessage) in
                    onError(errorMessage)
                })
            }
        }
    }
    
    
    //Saving the pushing up the dictionary from the profile view controller. This is called when the user updates their profile.
    func saveUserProfile(dict: Dictionary<String, Any>,  onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        //make sure the data is being updated for the current user.
        Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues(dict) { (error, dataRef) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        //use the built in auth reset password function.
        //This can be customized in Firebase in Auth
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    
    func logOut() {
        //user the built in FirebaseAuth functions
        do {
            try Auth.auth().signOut()
        } catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        //This will route us back to the initial view controller. See details in appDelegate
        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
    }
    
    //Used all over the place.
    func observeUsers(onSuccess: @escaping(UserCompletion)) {
        //returns a snapshot of each user. We can also listed for children added, this way it can be added to the snapshot, so we don't have to reload it all the time
        Ref().databaseUsers.observe(.childAdded) { (snapshot) in
            //the value of each snapshot is like a dictionary
            if let dict = snapshot.value as? Dictionary<String, Any> {
                //encapsulate these data dictionaries in an abstract class called 'user'
                //Now we will transfor the dictionary into an object
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    //Returns all users that the current user has liked
    func observeNewLike(onSuccess: @escaping(UserCompletion)) {
        Ref().databaseRoot.child("likes").child(Api.User.currentUserId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Bool] else { return }
            dict.forEach({ (key, value) in
                self.getUserInforSingleEvent(uid: key, onSuccess: { (user) in
                    onSuccess(user)
                })
            })
        }
    }
    
    //Returns all users that the current user has liked
    //'action' record whether or not the user was liked (Boolean)
    //used in the radar view controller
    func observeAction(onSuccess: @escaping(UserCompletion)) {
        Ref().databaseRoot.child("action").child(Api.User.currentUserId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Bool] else { return }
            dict.forEach({ (key, value) in
                self.getUserInforSingleEvent(uid: key, onSuccess: { (user) in
                    onSuccess(user)
                })
            })
        }
    }
    

    
    //For data that only needs to be changed one or infrequently (ie profile photos)
    //prevents cetrain loadings from happening multiple times like when we changed the profile photo in video 50
    func getUserInforSingleEvent(uid: String, onSuccess: @escaping(UserCompletion)) {
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    //allows up to return the user info of which ever user we pass into the uid aregument.
    func getUserInfo(uid: String, onSuccess: @escaping(UserCompletion)) {
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observe(.value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    
    //This observation method is used on to observe the match table
    func observeNewMatch(onSuccess: @escaping(UserCompletion)) {    Ref().databaseRoot.child("newMatch").child(Api.User.currentUserId).observeSingleEvent(of: .value) { (snapshot) in
        guard let dict = snapshot.value as? [String: Bool] else { return }
        dict.forEach({ (key, value) in
            self.getUserInforSingleEvent(uid: key, onSuccess: { (user) in
                onSuccess(user)
            })
        })
        }
    }
    
    
}
//in the api call the observeUsers functions can accept multiple closure arements. Be declaring typealias the alias name can be used anywhere in the app instead of the type. THe name reffers to an already existing type
typealias UserCompletion = (User) -> Void
