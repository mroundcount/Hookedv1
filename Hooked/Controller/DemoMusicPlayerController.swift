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

class DemoMusicPlayerController: UIViewController, AVAudioPlayerDelegate {
    
    //Roundcount Added
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var audio: Audio!
    var audioPlayer: AVAudioPlayer?
    var presented = false
    //End
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    
    let accessibilityDateComponentsFormatter = DateComponentsFormatter()
    
    var timer : Timer?
    
    var pauseBtn : UIBarButtonItem!
    var playBtn : UIBarButtonItem!
    var closeBtn : UIBarButtonItem!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let pauseBtn = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(pauseAction))
        //pauseBtn.accessibilityLabel = NSLocalizedString("Pause", comment: "")
        
        let playBtn = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(playAction))
        //playBtn.accessibilityLabel = NSLocalizedString("Play", comment: "")
        
        let closeBtn = UIBarButtonItem(image: UIImage(named: "close-1"), style: .plain, target: self, action: #selector(closeAction))
        //closeBtn.accessibilityLabel = NSLocalizedString("Closing", comment: "")
        
        let oldOS : Bool
        #if !targetEnvironment(macCatalyst)
        oldOS = ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10
        #else
        oldOS = false
        #endif
        
        popupItem.rightBarButtonItems = [ pauseBtn, closeBtn ]
        
        accessibilityDateComponentsFormatter.unitsStyle = .spellOut
        
    }
    
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
        
        
        //Roundcount Added
        if observation != nil {
            stopObservers()
        }
        
        let pauseBtn = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(pauseAction))
        let playBtn = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(playAction))
        let closeBtn = UIBarButtonItem(image: UIImage(named: "close-1"), style: .plain, target: self, action: #selector(closeAction))
        //End
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
    
    @objc func pauseAction() {
        print("pause action")
        player!.pause()
        popupItem.rightBarButtonItems = [ playBtn , closeBtn ] as? [UIBarButtonItem]
        //popupContentController.s3Transfer.pauseAudio()
        //popupContentController.stopTimer()
    }
    @objc func playAction() {
        print("play action")
        player!.play()
        popupItem.rightBarButtonItems = [ pauseBtn , closeBtn ] as? [UIBarButtonItem]
        //popupContentController.s3Transfer.resumeAudio()
        //popupContentController.startTimer()
    }
    
    @objc func closeAction() {
        print("close action")
        player!.pause()
        //self.pauseAction()
        self.dismissPopup()
    }
    func dismissPopup() {
        presented = false
        dismissPopupBar(animated: true, completion: nil)
    }
    
    /*
     func updateProgress(progress: Float) {
     popupContentController.popupItem.progress = progress
     }
     */
    //Roundcount Added
    
    
    
    func play(audio: Audio) {
        
        let audioUrl = audio.audioUrl
        if audioUrl.isEmpty {
            return
        }
        print("playing \(audioUrl)")
        
        //let url: URL = audioUrl.absoluteURL!
        
        //let url = URL(string: audioUrl)
        //let url = NSURL(string: audioUrl)
        //let url = URL(fileURLWithPath: audioUrl)
        
        //let path = Bundle.main.path(forResource: audioUrl, ofType: "MP3")!
        //let url = URL(fileURLWithPath: path)
        
        //let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: audioUrl, ofType: "mp3")!)
        //let url = URL.init(string: audioUrl)
        
        //let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(audioUrl).mp3")
        
        do {
            print("made it to play")
            print("this is the URL being generated \(audioUrl)")
            //print("this is the URL being generated \(url)")
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioUrl))
            print("made it past the tricky part")
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }

    
    
    //Known methof od working using AVPlayer
    var observation: Any? = nil
    
    func handlePlay(audio: Audio) {
        let audioUrl = audio.audioUrl
        if audioUrl.isEmpty {
            return
        }
        print("from handlePlay function: \(audioUrl)")
        
        if let url = URL(string: audioUrl) {
            print("made it to the function: \(audioUrl)")
            player = AVPlayer(url: url)
            observation = player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            player?.play()
        }
        print("finished handlePlay function")
    }
    
    func stopObservers() {
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
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
}
