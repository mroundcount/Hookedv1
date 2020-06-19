//
//  DemoMusicPlayerController.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/16/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import UIKit
import LNPopupController
import AVFoundation
import AVKit

import Firebase

class DemoMusicPlayerController: UIViewController, AVAudioPlayerDelegate {
    
    //Roundcount Added
    //var playerLayer: AVPlayerLayer?
    //var player: AVPlayer?
    var audio: Audio!
    var audioPlayer: AVAudioPlayer!
    var audioPath: URL!
    
    var presented = false
    var length : Float?
        
    //End
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    
    let accessibilityDateComponentsFormatter = DateComponentsFormatter()
    
    var timer : Timer?
    var pauseBtn : UIBarButtonItem!
    var playBtn : UIBarButtonItem!
    var closeBtn : UIBarButtonItem!
    
    var songTitle: String = "" {
        didSet {
            if isViewLoaded {
                songNameLabel.text = songTitle
            }
            
            popupItem.title = songTitle
        }
    }
    
    var artistName: String = "" {
        didSet {
            if isViewLoaded {
                artistNameLabel.text = artistName
            }
            popupItem.subtitle = artistName
        }
    }
    
    var albumTitle: String = "" {
        didSet {
            if isViewLoaded {
                albumNameLabel.text = albumTitle
            }
            /*
             #if !targetEnvironment(macCatalyst)
             if ProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 9 {
             popupItem.subtitle = albumTitle
             }
             #endif
             */
        }
    }
    
    var albumArt: UIImage = UIImage() {
        didSet {
            if isViewLoaded {
                albumArtImageView.image = albumArt
            }
            popupItem.image = albumArt
            popupItem.accessibilityImageLabel = NSLocalizedString("Album Art", comment: "")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songNameLabel.text = songTitle
        artistNameLabel.text = artistName
        albumNameLabel.text = albumTitle
        albumArtImageView.image = albumArt
        
        if #available(iOS 13.0, *) {
            albumArtImageView.layer.cornerCurve = .continuous
        }
        albumArtImageView.layer.cornerRadius = 16
        
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(DemoMusicPlayerController._timerTicked(_:)), userInfo: nil, repeats: true)
        
        pauseBtn = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(pauseAction))
        playBtn = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(playAction))
        closeBtn = UIBarButtonItem(image: UIImage(named: "close-1"), style: .plain, target: self, action: #selector(closeAction))
        //End
        popupItem.rightBarButtonItems = [ pauseBtn, closeBtn ]
        
    }
    
    @objc func pauseAction() {
        print("pause action")
        audioPlayer!.pause()
        popupItem.rightBarButtonItems = [ playBtn , closeBtn ] as? [UIBarButtonItem]
        //popupContentController.stopTimer()
    }
    
    @objc func playAction() {
        print("play action")
        audioPlayer!.play()
        popupItem.rightBarButtonItems = [ pauseBtn , closeBtn ] as? [UIBarButtonItem]
        //popupContentController.startTimer()
    }
    
    @objc func closeAction() {
        print("close action")
        audioPlayer!.stop()
        self.dismissPopup()
    }
    
    func dismissPopup() {
        presented = false
        popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
    }
    
    
    
    
    @objc func _timerTicked(_ timer: Timer) {
        popupItem.progress += 0.0002;
        popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
        
        let totalTime = TimeInterval(250)
        popupItem.accessibilityProgressValue = "\(accessibilityDateComponentsFormatter.string(from: TimeInterval(popupItem.progress) * totalTime)!) \(NSLocalizedString("of", comment: "")) \(accessibilityDateComponentsFormatter.string(from: totalTime)!)"
        
        progressView.progress = popupItem.progress
        
        if popupItem.progress >= 1.0 {
            timer.invalidate()
            popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    //Known methof of working using AVPlayer
    /*
    var observation: Any? = nil
    
    func handlePlay(audio: Audio) {
        
        let audioUrl = audio.audioUrl
        if audioUrl.isEmpty {
            return
        }
        print("from handlePlay function: \(audioUrl)")
        
        if let url = URL(string: audioUrl) {
            print("made it to the function: \(audioUrl)")
            //activityIndicatorView.isHidden = false
            //activityIndicatorView.startAnimating()
            stopObservers()
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            observation = player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            player?.play()
            //playButton.isHidden = true
        }
        
    }
    
    func stopObservers() {
        print("sup Drew function called")
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("observeValue called")
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
 */
}
