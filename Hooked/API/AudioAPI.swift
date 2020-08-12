//
//  AudioAPI.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/8/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import Firebase

class AudioApi {
    //uploaded an audio file
    func uploadAudio(artist: String, value: Dictionary<String, Any>) {
        let ref = Ref().databaseAudioArtist(artist: artist)
        ref.childByAutoId().updateChildValues(value)
    }
    
    func uploadAudioFile(value: Dictionary<String, Any>) {
        let ref = Ref().databaseAudioFileOnly()
        ref.childByAutoId().updateChildValues(value)
    }
    
    //pulls down the audio info
    func pullAudio(artist: String, onSuccess: @escaping(Audio) -> Void) {
        let ref = Ref().databaseAudioArtist(artist: artist)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let audio = Audio.transformAudio(dict: dict, keyId: snapshot.key) {
                    onSuccess(audio)
                }
            }
        }
    }
    
    func observeNewLike(onSuccess: @escaping(AudioCompletion)) {
        Ref().databaseRoot.child("likes").child(Api.User.currentUserId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Bool] else { return }
            dict.forEach({ (key, value) in
                self.getUserInforSingleEvent(id: key, onSuccess: { (audio) in
                    onSuccess(audio)
                })
            })
        }
    }
    
    func getUserInforSingleEvent(id: String, onSuccess: @escaping(AudioCompletion)) {
        let ref = Ref().databaseSpecificAudio(id: id)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let audio = Audio.transformAudio(dict: dict, keyId: snapshot.key) {
                    onSuccess(audio)
                }
            }
        }
    }
    
    func observeAudio(onSuccess: @escaping(Audio) -> Void) {
        //returns a snapshot of each user. We can also listed for children added, this way it can be added to the snapshot, so we don't have to reload it all the time
        Ref().databaseAudioFileOnly().observe(.childAdded) { (snapshot) in
            //the value of each snapshot is like a dictionary
            if let dict = snapshot.value as? Dictionary<String, Any> {
                //encapsulate these data dictionaries in an abstract class called 'user'
                //Now we will transfor the dictionary into an object
                if let audio = Audio.transformAudio(dict: dict, keyId: snapshot.key) {
                    onSuccess(audio)
                }
            }
        }
    }
}

typealias AudioCompletion = (Audio) -> Void


class FirebaseManager {
    static let shared = FirebaseManager()
    private let reference = Database.database().reference()
}


// MARK: - Removing functions
/*
extension FirebaseManager {
    public func removePost(withID: String) {
        //FirebaseManager.shared.removePost(withID: (cell?.audio.id)!)
        let reference = Ref().databaseAudioArtist(artist: Api.User.currentUserId).child("-MDgle7VEpkf8_KTVIW-")
        print("Reference from deletion: \(reference)")
        reference.removeValue { error, _ in
            print(error!.localizedDescription)
        }
        //FirebaseManager.shared.removePost(withID: (cell?.audio.id)!)
    }
}
*/
