//
//  AudioCard.swift
//  Hooked
//
//  Created by Michael Roundcount on 6/30/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//


import UIKit
import CoreLocation

import AVFoundation
import AVKit

class AudioCard: UIView {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var nopeView: UIView!
    @IBOutlet weak var nopeLbl: UILabel!

    var controller: AudioRadarViewController!
    var AudioFile: [Audio] = []
    
    var audioPlayer: AVAudioPlayer!
    var audioPath: URL!
    
    //My modifications to it.
    var audio: Audio! {
       //pass the user object the array and create a new card, then append the card to the cards array
        didSet {
            Api.User.getUserInforSingleEvent(uid: audio.artist) { (user) in
            
                self.photo.loadImage(user.profileImageUrl)

                let attributedArtistText = NSMutableAttributedString(string: "\(user.username)  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.white])
                
                //self.usernameLbl.attributedText = attributedArtistText
                self.usernameLbl.attributedText = attributedArtistText
            }

            let attributedTitleText = NSMutableAttributedString(string: "\(audio.title)  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30), NSAttributedString.Key.foregroundColor : UIColor.white])
            self.titleLbl.attributedText = attributedTitleText
            
            print("from the cards themselves: \(audio.title)")
            
            //downloadFile(audio: audio)
        }
    }

    //I don't think much needs to me modified here.
     override func awakeFromNib() {
         super.awakeFromNib()
        
        //adding gradient to the avatar
         backgroundColor = .clear
         let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: bounds.height)
        //rounding the corners
         photo.addBlackGradientLayer(frame: frameGradient, colors: [.clear, .black])
         photo.layer.cornerRadius = 10
         photo.clipsToBounds = true
         
        //styling the like and nope icons
         likeView.alpha = 0
         nopeView.alpha = 0
         
         likeView.layer.borderWidth = 3
         likeView.layer.cornerRadius = 5
         likeView.clipsToBounds = true
         likeView.layer.borderColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1).cgColor
         
         nopeView.layer.borderWidth = 3
         nopeView.layer.cornerRadius = 5
         nopeView.clipsToBounds = true
         nopeView.layer.borderColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1).cgColor
        
        //rotating the cards as we move them from side to side
         likeView.transform = CGAffineTransform(rotationAngle: -.pi / 8)
         nopeView.transform = CGAffineTransform(rotationAngle: .pi / 8)
         
        //added in extension
         nopeLbl.addCharacterSpacing()
         nopeLbl.attributedText = NSAttributedString(string: "NOPE",attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)])

         nopeView.layer.borderColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1).cgColor
         nopeLbl.textColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1)
         
        //added in extension
         likeLbl.addCharacterSpacing()
         likeLbl.attributedText = NSAttributedString(string: "LIKE",attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)])
         likeView.layer.borderColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1).cgColor
         likeLbl.textColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1)
        
         
     }
    
     //switch to the detail view for each card
     @IBAction func infoBtnDidTap(_ sender: Any) {
        print("navigate did tap")

        /*
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
         detailVC.user = user
         
         self.controller.navigationController?.pushViewController(detailVC, animated: true)
         */
     }
    
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
                    //gotAudioLength()
                    //audioPlayer.delegate = self
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
                        //self.gotAudioLength()
                        //self.updateSlider()
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
    
    
}
