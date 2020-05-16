//
//  AudioTableViewCell.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/14/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var audio: Audio!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //photoMessage.isHidden = true
        //profileImage.isHidden = true
        //textMessageLabel.isHidden = true
        
        if observation != nil {
            stopObservers()
        }
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        playButton.isHidden = false
        //activityIndicatorView.isHidden = true
        //activityIndicatorView.stopAnimating()
    }
    
    func stopObservers() {
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
    }
    
    //modified to remove image
    func configureCell(uid: String, audio: Audio) {
        self.audio = audio
        let titleText = audio.title
        if !titleText.isEmpty {
            titleLbl.isHidden = false
            titleLbl.text = audio.title
        }
        
        let genreText = audio.genre
        if !genreText.isEmpty {
            genreLbl.isHidden = false
            genreLbl.text = audio.genre
        }

        //We'll do test styling in here too
        let date = Date(timeIntervalSince1970: audio.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dataLbl.text = dateString
        
    }
    
    @IBAction func playBtnDidTapped(_ sender: Any) {
        handlePlay()
    }
    
    var observation: Any? = nil
    
    func handlePlay() {
 
           let audioUrl = audio.audioUrl
           if audioUrl.isEmpty {
               return
           }
           print("from handlePlay function: \(audioUrl)")
           
           if let url = URL(string: audioUrl) {
               print("made it to the function: \(audioUrl)")
               //activityIndicatorView.isHidden = false
               //activityIndicatorView.startAnimating()
               player = AVPlayer(url: url)
               playerLayer = AVPlayerLayer(player: player)
               playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
               observation = player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
               player?.play()
               //playButton.isHidden = true
           }
    
       }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status: AVPlayer.Status = player!.status
            switch (status) {
            case AVPlayer.Status.readyToPlay:
                //activityIndicatorView.isHidden = true
                //activityIndicatorView.stopAnimating()
                break
            case AVPlayer.Status.unknown, AVPlayer.Status.failed:
                break
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
