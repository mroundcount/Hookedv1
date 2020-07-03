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
    
    func observeAudio(onSuccess: @escaping(UserCompletion)) {
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
}
