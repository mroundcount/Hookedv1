//
//  AudioRadarViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 6/30/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import GeoFire
import CoreLocation
import FirebaseDatabase
import ProgressHUD

import AVFoundation
import AVKit

class AudioRadarViewController: UIViewController {
    
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    
    //added
    var audioCollection: [Audio] = []
    var likesCollection: [Audio] = []
    var cards: [AudioCard] = []

    //var likes = [String]()
    
    //detecting the position of the card at it's inital position
    var cardInitialLocationCenter: CGPoint!
    var panInitialLocation: CGPoint!
    
    var audio: Audio!
    var audioPlayer: AVAudioPlayer!
    var audioPath: URL!
    
    @IBOutlet weak var cardStack: UIView!
    @IBOutlet weak var refreshImg: UIImageView!
    @IBOutlet weak var nopeImg: UIImageView!
    @IBOutlet weak var superLikeImg: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var boostImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.findAudioFiles()
        
        
        title = "Hooked"
        //configureLocationManager()
        nopeImg.isUserInteractionEnabled = true
        let tapNopeImg = UITapGestureRecognizer(target: self, action: #selector(nopeImgDidTap))
        nopeImg.addGestureRecognizer(tapNopeImg)
        
        likeImg.isUserInteractionEnabled = true
        let tapLikeImg = UITapGestureRecognizer(target: self, action: #selector(likeImgDidTap))
        likeImg.addGestureRecognizer(tapLikeImg)
        
        let newMatchItem = UIBarButtonItem(image: UIImage(named: "icon-chat"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(newMatchItemDidTap))
        self.navigationItem.rightBarButtonItem = newMatchItem

    }
    
    func findAudioFiles () {
        Api.Audio.observeAudio { (results) in
            self.audioCollection.append(results)
            //self.setupCard(audio: audio)
            //print("AudioCards being displayed \(results.title) by: \(results.artist)")
        }

        Api.Audio.observeNewLike { (likedAudio) in
            self.likesCollection.append(likedAudio)
            //self.tableView.reloadData()
            //print("Audio to remove... \(likedAudio.title)")
            
            for likedAudio in self.likesCollection
            {
                let audio = self.audioCollection.filter({ $0.id != likedAudio.id })
                
                for audio in audio {
                    //print("final audio list: \(audio.title)")
                    self.setupCard(audio: audio)
                }
            }
        }
    }
    
    //saving the true of false to the current user logged in
    func saveToFirebase(like: Bool, card: AudioCard) {
        Ref().databaseActionForUser(uid: Api.User.currentUserId)
            .updateChildValues([card.audio.id: like]) { (error, ref) in
                if error == nil, like == true {
                    // check if match { send push notificaiton }
                    //self.checkIfMatchFor(card: card)
                }
        }
    }
    
    //saving only true like values to the firebase so can can just view them in a liked page.
    func saveLikesToFirebase(like: Bool, card: AudioCard) {
        Ref().databaseLikesForUser(uid: Api.User.currentUserId)
            .updateChildValues([card.audio.id: like]) { (error, ref) in
                if error == nil, like == true {
                }
        }
    }
    
    //move to the next card in the array
    func updateCards(card: AudioCard) {
        
        
       
        
        //use enumderated method to this
        for (index, c) in self.cards.enumerated() {
          
            if c.audio.id == card.audio.id {
                self.cards.remove(at: index)
                self.audioCollection.remove(at: index)
            }
            
        }
        setupGestures()
        if cards.count == 1 {
            print("Playing the friggen 3 \(audio.title)")
        }
        //setupTransforms()
    }
    
    //confifure the card frame and pass in the user parameter and append it to the card array
    func setupCard(audio: Audio) {
        let card: AudioCard = UIView.fromNib()
        card.frame = CGRect(x: 0, y: 0, width: cardStack.bounds.width, height: cardStack.bounds.height)
        card.audio = audio
        //passing the radar controller to the card object
        card.controller = self
        cards.append(card)
        //append the stack view of arrays
        cardStack.addSubview(card)
        cardStack.sendSubviewToBack(card)
        //allows us to see the full stack of the cards.
        //setupTransforms()
                
        //make sure that only the top card is being interacted with
        if cards.count == 1 {
            cardInitialLocationCenter = card.center
            print("Playing the friggen 3 \(audio.title)")
            downloadFile(audio: audio)
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
        }
        
        //print("Playing the friggen 5 \(audio.title)")
        //downloadFile(audio: audio)
    }
    
    @objc func newMatchItemDidTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newMatchVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_NEW_MATCH) as! NewMatchTableViewController
        self.navigationController?.pushViewController(newMatchVC, animated: true)
    }
    //creating swipe animation
    @objc func nopeImgDidTap() {
        guard let firstCard = cards.first else {
            return
        }
        //move the card to the left
        //save it to the firstbase
        saveToFirebase(like: false, card: firstCard)
        swipeAnimation(translation: -750, angle: -15)
        //self.setupTransforms()
    }
    
    //creating swipe animation
    @objc func likeImgDidTap() {
        guard let firstCard = cards.first else {
            return
        }
        //move the card to the right
        //save it to the firstbase
        saveToFirebase(like: true, card: firstCard)
        //only saving likes to the liked table
        saveLikesToFirebase(like: true, card: firstCard)
        swipeAnimation(translation: 750, angle: 15)
        //self.setupTransforms()
    }
    
    //actual animation for swiping
    func swipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        guard let firstCard = cards.first else {
            return
        }
        //take the card out of the array once it has been moved
        for (index, c) in self.cards.enumerated() {
            if c.audio.id == firstCard.audio.id {
                self.cards.remove(at: index)
                self.audioCollection.remove(at: index)
            }
        }
        
        
        //sets up the pan gesture if you use the button instead of the swipe gesture
        self.setupGestures()
        
        CATransaction.setCompletionBlock {
            
            firstCard.removeFromSuperview()
        }
        firstCard.layer.add(translationAnimation, forKey: "translation")
        firstCard.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    //diabling the title area and the navigation bar the bottom
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        //tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        //tabBarController?.tabBar.isHidden = false
    }
    
    //all the responsibility of moving the card view is on this pan gesture
    @objc func pan(gesture: UIPanGestureRecognizer) {
        let card = gesture.view! as! AudioCard
        //cg point value so we know where the card is being swiped
        let translation = gesture.translation(in: cardStack)
        
        switch gesture.state {
        case .began:
            panInitialLocation = gesture.location(in: cardStack)
            
        //look where the card is moving in the gesture
        case .changed:
            //print("changed")
            //print("x: \(translation.x)")
            //print("y: \(translation.y)")
            
            card.center.x = cardInitialLocationCenter.x + translation.x
            card.center.y = cardInitialLocationCenter.y + translation.y
            
            if translation.x > 0 {
                // show like icon
                // 0<= alpha <=1
                //dfading the icon in and out
                card.likeView.alpha = abs(translation.x * 2) / cardStack.bounds.midX
                card.nopeView.alpha = 0
            } else {
                // show unlike icon
                card.nopeView.alpha = abs(translation.x * 2) / cardStack.bounds.midX
                card.likeView.alpha = 0
            }
            //adding smoothness to the transition
            card.transform = self.transform(view: card, for: translation)
        //check where the card is at the end of the gestire and deciding to sent true of false to the database
        case .ended:
            //threshold for like
            if translation.x > 75 {
                UIView.animate(withDuration: 0.3, animations: {
                    //setting the threshold for the card once it has been moved. If it moves past this point then we complete move it off the page
                    card.center = CGPoint(x: self.cardInitialLocationCenter.x + 1000, y: self.cardInitialLocationCenter.y + 1000)
                }) { (bool) in
                    // remove card
                    card.removeFromSuperview()
                }
                saveToFirebase(like: true, card: card)
                //only saving likes to the liked table
                saveLikesToFirebase(like: true, card: card)
                //apply the same logic to the next card in the stact
                self.updateCards(card: card)
                
                return
            } else if translation.x < -75 {
                
                UIView.animate(withDuration: 0.3, animations: {
                    //get the card back to it's origional position if the threshold has not been met
                    card.center = CGPoint(x: self.cardInitialLocationCenter.x - 1000, y: self.cardInitialLocationCenter.y + 1000)
                }) { (bool) in
                    // remove card
                    card.removeFromSuperview()
                }
                
                saveToFirebase(like: false, card: card)
                self.updateCards(card: card)
                
                return
            }
            
            //initialize the card position after release if a decision is not made
            UIView.animate(withDuration: 0.3) {
                card.center = self.cardInitialLocationCenter
                card.likeView.alpha = 0
                card.nopeView.alpha = 0
                card.transform = CGAffineTransform.identity
            }
        default:
            break
        }
    }
    
    //adding the pan gesture to the next card in the array
    func setupGestures() {
        for card in cards {
            let gestures = card.gestureRecognizers ?? []
            for g in gestures {
                card.removeGestureRecognizer(g)
            }
        }
        
        if let firstCard = cards.first {
            firstCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
            
            print("Playing the friggen 7: \(String(describing: cards.first?.audio.title))")
            downloadFile(audio: (cards.first?.audio)!)
        }
    }
    
    //tilting the card while swiping
    func transform(view: UIView, for translation: CGPoint) -> CGAffineTransform {
        let moveBy = CGAffineTransform(translationX: translation.x, y: translation.y)
        //having the rotation at a negative anchors the card at the top instead of the bottom
        let rotation = -translation.x / (view.frame.width / 2)
        return moveBy.rotated(by: rotation)
    }
    
    //laying out the rest of the card list once the top card has been moved off the screen
    //This gives the cards layout showing the corners of the upcoming ones. Purely cosmetic
    func setupTransforms() {
        for (i, card) in cards.enumerated() {
            if i == 0 { continue; }
            
            if i > 3 { return }
            
            var transform = CGAffineTransform.identity
            if i % 2 == 0 {
                transform = transform.translatedBy(x: CGFloat(i)*4, y: 0)
                transform = transform.rotated(by: CGFloat(Double.pi)/150*CGFloat(i))
            } else {
                transform = transform.translatedBy(x: -CGFloat(i)*4, y: 0)
                transform = transform.rotated(by: -CGFloat(Double.pi)/150*CGFloat(i))
            }
            
            card.transform = transform
        }
    }
}

