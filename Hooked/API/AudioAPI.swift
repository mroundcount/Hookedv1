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
    func uploadAudio(artist: String, value: Dictionary<String, Any>) {
        let ref = Ref().databaseAudioArtist(artist: artist)
        ref.childByAutoId().updateChildValues(value)
    }
    
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
}
