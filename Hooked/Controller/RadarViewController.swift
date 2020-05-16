//
//  RadarViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/30/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import GeoFire
import CoreLocation
import FirebaseDatabase
import ProgressHUD

class RadarViewController: UIViewController {
    
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    var users: [User] = []
    var cards: [Card] = []
    var likes = [String]()
    var allUsers = [String]()
    var final = [String]()
    //detecting the position of the card at it's inital position
    var cardInitialLocationCenter: CGPoint!
    var panInitialLocation: CGPoint!
    
    @IBOutlet weak var cardStack: UIView!
    @IBOutlet weak var refreshImg: UIImageView!
    @IBOutlet weak var nopeImg: UIImageView!
    @IBOutlet weak var superLikeImg: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var boostImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.findUsers()
        
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
        
        findAction()
        //print(users)
    }
    
    //copying the function from the people around view controller. May update this later once we can get the observation fixed
        
    func findAction() {
        Api.User.observeAction { (user) in
            //self.users.removeAll()
            self.users.append(user)
            self.setupCard(user: user)
            print("action database:",user.username)
            Ref().databaseRoot.child("action").child(Api.User.currentUserId).updateChildValues([user.uid: true])
            return
        }
    }
    
    
    func findUsers () {
        
         Api.User.observeNewLike { (user) in
         //self.users.removeAll()
         self.users.append(user)
         //print("liked users: ",user.username)
         //self.likes.append(user.username)
         //print("already liked users:",self.likes)
         }
        
        Api.User.observeUsers { (user) in
            //self.users.removeAll()
            self.users.append(user)                        
            self.setupCard(user: user)
            //print(user.username)
            return
        }
        
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
    
    //saving the true of false to the current user logged in
    func saveToFirebase(like: Bool, card: Card) {
        Ref().databaseActionForUser(uid: Api.User.currentUserId)
            .updateChildValues([card.user.uid: like]) { (error, ref) in
                if error == nil, like == true {
                    // check if match { send push notificaiton }
                    self.checkIfMatchFor(card: card)
                }
        }
    }
    
    //saving only true like values to the firebase so can can just view them in a liked page.
    func saveLikesToFirebase(like: Bool, card: Card) {
        Ref().databaseLikesForUser(uid: Api.User.currentUserId)
            .updateChildValues([card.user.uid: like]) { (error, ref) in
                if error == nil, like == true {
                }
        }
    }
    
    //looking for a match checked by userID
    func checkIfMatchFor(card: Card) {
        //pull all the swiping information on the card userID
        Ref().databaseActionForUser(uid: card.user.uid).observeSingleEvent(of: .value) { (snapshot) in
            //looking if this card contains the true value for the current userID
            guard let dict = snapshot.value as? [String: Bool] else { return }
            //logic for checking if both users like each other.
            //looking if the user logged in also has a liked value from the user on the card
            if dict.keys.contains(Api.User.currentUserId), dict[Api.User.currentUserId] == true {
                Ref().databaseRoot.child("newMatch").child(Api.User.currentUserId).updateChildValues([card.user.uid: true])
                Ref().databaseRoot.child("newMatch").child(card.user.uid).updateChildValues([Api.User.currentUserId: true])
                
            }
        }
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
            if c.user.uid == firstCard.user.uid {
                self.cards.remove(at: index)
                self.users.remove(at: index)
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
    
    //confifure the card frame and pass in the user parameter and append it to the card array
    func setupCard(user: User) {
        let card: Card = UIView.fromNib()
        card.frame = CGRect(x: 0, y: 0, width: cardStack.bounds.width, height: cardStack.bounds.height)
        card.user = user
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
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
        }
        
    }
    //all the responsibility of moving the card view is on this pan gesture
    @objc func pan(gesture: UIPanGestureRecognizer) {
        let card = gesture.view! as! Card
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
    //move to the next card in the array
    func updateCards(card: Card) {
        //use enumderated method to this
        for (index, c) in self.cards.enumerated() {
            if c.user.uid == card.user.uid {
                self.cards.remove(at: index)
                self.users.remove(at: index)
            }
        }
        
        setupGestures()
        //setupTransforms()
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
    
    /*
     func observeLikedUsers() {
     self.users.removeAll()
     //returns all users in the "likes" database.
     Api.User.observeNewLike { (user) in
     self.users.append(user)
     //print("liked users: ",user.username)
     self.likes.append(user.username)
     print("already liked users:",self.likes)
     }
     }
     */
}
