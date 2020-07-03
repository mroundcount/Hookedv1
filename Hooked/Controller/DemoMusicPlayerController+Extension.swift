//
//  DemoMusicPlayerController+Extension.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/22/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import UIKit
import LNPopupController
import AVFoundation
import AVKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

extension DemoMusicPlayerController {

    //This is the one we'll be using
    //https://mobikul.com/play-audio-file-save-document-directory-ios-swift/
    func downloadFile(audio: Audio) {
        
        let audioUrl = audio.audioUrl
        if audioUrl.isEmpty {
            return
        }
        
        if let audioUrl = URL(string: audioUrl) {
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                    //guard let player = self.audioPlayer else { return }
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    //startTimer()
                    gotAudioLength()
                    audioPlayer.delegate = self
                    print("playing \(audio.title)")
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                // if the file doesn't exist
            } else {
                // you can use NSURLSession.sharedSession to download the data asynchronously
                print("Have to download the URL")
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        
                        print("playing audio from the download file step")
                        self.audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                        //guard let player = self.audioPlayer else { return }
                        self.audioPlayer?.prepareToPlay()
                        self.audioPlayer?.play()
                        //self.startTimer()
                        self.gotAudioLength()
                        self.updateSlider()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }

    func stopAudio() {
        print("stop called")
            audioPlayer?.stop()
        }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished")
        audioPlayer?.stop()
        stopTimer()
        popupItem.rightBarButtonItems = [ playBtn , closeBtn ] as? [UIBarButtonItem]
    }

}

