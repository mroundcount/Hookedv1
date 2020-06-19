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
import AVFoundation

//We'll put all business logic and methods for Firebase storage into this helper class. We'll go here everytime we want to access of download storage data.
class StorageService {
    
    static func saveAudioFile(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let ref = Ref().storageSpecificAudio(id: id)
        
        let metadata = StorageMetadata()
        metadata.contentType = "audio/mp3"
        
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            ref.downloadURL(completion: { (audioUrl, error) in
                print("from step 3 \(url)")
                if let metaAudioUrl = audioUrl?.absoluteString {
                    let dict: Dictionary<String, Any> = [
                        "audioUrl": metaAudioUrl as Any,
                        "height": 720,
                        "width": 1280
                    ]
                    onSuccess(dict)
                }
            })
        }
    }
    
    static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let ref = Ref().storageSpecificVideoMessage(id: id)
        
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            ref.downloadURL(completion: { (videoUrl, error) in
                if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                    StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
                        
                        if let dict = value as? Dictionary<String, Any> {
                            var dictValue = dict
                            if let videoUrlString = videoUrl?.absoluteString {
                                dictValue["videoUrl"] = videoUrlString
                            }
                            onSuccess(dictValue)
                        }
                    }, onError: { (errorMessage) in
                        onError(errorMessage)
                    })
                }
            })
        }
    }
    
    static func saveAudioMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let ref = Ref().storageSpecificAudioMessage(id: id)
        
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            ref.downloadURL(completion: { (audioUrl, error) in
                if let metaAudioUrl = audioUrl?.absoluteString {
                    let dict: Dictionary<String, Any> = [
                        "audioUrl": metaAudioUrl as Any,
                        "height": 720,
                        "width": 1280
                        //"text": "" as Any
                    ]
                    onSuccess(dict)
                }
            })
        }
    }
    
    
    static func thumbnailImageForFileUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func savePhotoMessage(image: UIImage?, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        if let imagePhoto = image {
            let ref = Ref().storageSpecificImageMessage(id: id)
            if let data = imagePhoto.jpegData(compressionQuality: 0.5) {
                
                ref.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                    }
                    ref.downloadURL(completion: { (url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            let dict: Dictionary<String, Any> = [
                                "imageUrl": metaImageUrl as Any,
                                "height": imagePhoto.size.height as Any,
                                "width": imagePhoto.size.width as Any,
                                "text": "" as Any
                            ]
                            onSuccess(dict)
                        }
                    })
                }
            }
        }
    }
    
    
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
