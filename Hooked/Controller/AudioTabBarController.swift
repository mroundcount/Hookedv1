//
//  AudioTabBarController.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/16/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import LNPopupController

class AudioTabBarController: UITabBarController {
    
    var popupContentController : AudioPlayerViewController!
    var pauseBtn : UIBarButtonItem!
    var playBtn : UIBarButtonItem!
    var nextBtn : UIBarButtonItem!
    var closeBtn : UIBarButtonItem!
    var presented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load")
        // Do any additional setup after loading the view.
        popupContentController = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as? AudioPlayerViewController
        pauseBtn = UIBarButtonItem(image: UIImage(named: "pause-mini"), style: .plain, target: self, action: #selector(pauseAction))
        playBtn = UIBarButtonItem(image: UIImage(named: "play-mini"), style: .plain, target: self, action: #selector(playAction))
        //nextBtn = UIBarButtonItem(image: UIImage(named: "next-mini"), style: .plain, target: self, action: #selector(nextAction))
        closeBtn = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(closeAction))
    }
    
    func showAudioPlayer(title: String, subtitle: String) {
        self.pauseAction()
        popupContentController.popupItem.title = title
        popupContentController.popupItem.subtitle = subtitle
        self.popupBar.progressViewStyle = LNPopupBarProgressViewStyle.bottom
        popupContentController.popupItem.rightBarButtonItems = [ pauseBtn , nextBtn , closeBtn ] as? [UIBarButtonItem]
        
        if(!presented) {
            self.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
            presented = true
        } else {
            print("already presented")
        }
        
    }
    
    func updateProgress(progress: Float) {
        popupContentController.popupItem.progress = progress
    }
    
    /*
    func addPostToQueue(post: Post) {
        print("inside add post presented: ")
        print(presented)
        if(!presented) {
            self.showAudioPlayer(title: post.description!, subtitle: post.username!)
            popupContentController.playPost(post: post)
        } else {
            popupContentController.addPostToQueue(post: post)
        }
    }
    */
    
    func dismissPopup() {
        presented = false
        dismissPopupBar(animated: true, completion: nil)
    }
    //MARK: - BarButton Actions
    
    @objc func pauseAction() {
        print("pause action")
        popupContentController.popupItem.rightBarButtonItems = [ playBtn , nextBtn , closeBtn ] as? [UIBarButtonItem]
        popupContentController.s3Transfer.pauseAudio()
        popupContentController.stopTimer()
    }
    
    @objc func playAction() {
        print("play action")
        popupContentController.popupItem.rightBarButtonItems = [ pauseBtn , nextBtn , closeBtn ] as? [UIBarButtonItem]
        popupContentController.s3Transfer.resumeAudio()
        popupContentController.startTimer()
    }
    /*
    @objc func nextAction() {
        print("next action")
        popupContentController.stopTimer()
        popupContentController.s3Transfer.pauseAudio()
        popupContentController.nextPost()
    }
    */
    
    @objc func closeAction() {
        print("close action")
        self.pauseAction()
        self.dismissPopup()
    }
    
}
