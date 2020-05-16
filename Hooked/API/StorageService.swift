//
//  StorageService.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/6/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD


//We'll put all business logic and methods for Firebase storage into this helper class. We'll go here everytime we want to access of download storage data.
class StorageService {
    
    
    //Saving an updated profile image
    //inputs for user id and image to pass thru
    static func savePhotoProfile(image: UIImage, uid: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        //modified from UserAPI to correspond with the parameters of this specifc method
        let storageProfileRef = Ref().storageSpecificProfile(uid: uid)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        //Actually saving the image up the databsae.
        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                    Ref().databaseSpecificUser(uid: uid).updateChildValues([PROFILE_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
        })
    }
    
    static func savePhoto(username: String, uid: String, data: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {

        storageProfileRef.putData(data, metadata: metadata, completion: {
            (StorageMetadata, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            storageProfileRef.downloadURL(completion: {(url, error) in
                if let metaImageUrl = url?.absoluteString {
                    //call and storing the current info in firebase once they sign in
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.displayName = username
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                            
                        })
                    }
                    //Creating a dictionary for the photo
                    var dictTemp = dict
                    dictTemp[PROFILE_IMAGE_URL] = metaImageUrl
                    
                    Ref().databaseSpecificUser(uid: uid).updateChildValues(dictTemp, withCompletionBlock: {
                            (error, ref) in
                            if error == nil {
                                onSuccess()
                            } else {
                                onError(error!.localizedDescription)
                            }
                        })
                }
            })
        })
    }
}
