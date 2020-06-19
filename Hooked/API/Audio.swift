//
//  Audio.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/8/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation

class Audio {
    var id: String
    var artist: String
    var artistName: String
    var date: Double
    var title: String
    var genre: String
    var audioUrl: String
    
    init(id: String, artist: String, artistName: String, date: Double, title: String, genre: String, audioUrl: String) {
        self.id = id
        self.artist = artist
        self.artistName = artistName
        self.date = date
        self.title = title
        self.genre = genre
        self.audioUrl = audioUrl
    }
    
    static func transformAudio(dict: [String: Any], keyId: String) -> Audio? {
        guard let artist = dict["artist"] as? String,
            let date = dict["date"] as? Double else {
                return nil
        }
        let artistName = (dict["artistName"] as? String) == nil ? "" : (dict["artistName"]! as! String)
        let title = (dict["title"] as? String) == nil ? "" : (dict["title"]! as! String)
        let genre = (dict["genre"] as? String) == nil ? "" : (dict["genre"]! as! String)
        let audioUrl = (dict["audioUrl"] as? String) == nil ? "" : (dict["audioUrl"]! as! String)
                
        let audio = Audio(id: keyId, artist: artist, artistName: artistName, date: date, title: title, genre: genre, audioUrl: audioUrl)

        return audio
    }
}

