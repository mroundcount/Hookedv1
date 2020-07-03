//
//  AudioCard.swift
//  Hooked
//
//  Created by Michael Roundcount on 6/30/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//


/*

import UIKit
import CoreLocation

class AudioCard: UIView {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var nopeView: UIView!
    @IBOutlet weak var nopeLbl: UILabel!

    var controller: AudioRadarViewController!

    //extracting info from the user object
     var user: User! {
        //pass the user object the array and create a new card, then append the card to the cards array
         didSet {
             photo.loadImage(user.profileImageUrl) { (image) in
                 self.user.profileImage = image
             }
             //using attributed string from earlier lessons to combine the username and age
             let attributedUsernameText = NSMutableAttributedString(string: "\(user.username)  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30), NSAttributedString.Key.foregroundColor : UIColor.white])
            
            //the age can be nil so be sure to check it.
            //CHANGE
            var age = ""
             if let ageValue = user.age {
                 age = String(ageValue)
             }
             let attributedAgeText = NSMutableAttributedString(string: age, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.white])
             attributedUsernameText.append(attributedAgeText)
             
             usernameLbl.attributedText = attributedUsernameText
         }
     }
     
    //My modifications to it.
    var audio: Audio! {
       //pass the user object the array and create a new card, then append the card to the cards array
        
        
        
        didSet {
            photo.loadImage(user.profileImageUrl) { (image) in
                self.user.profileImage = image
            }
            //using attributed string from earlier lessons to combine the username and age
            let attributedUsernameText = NSMutableAttributedString(string: "\(user.username)  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30), NSAttributedString.Key.foregroundColor : UIColor.white])
           
           //the age can be nil so be sure to check it.
           //CHANGE
           var age = ""
            if let ageValue = user.age {
                age = String(ageValue)
            }
            let attributedAgeText = NSMutableAttributedString(string: age, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.white])
            attributedUsernameText.append(attributedAgeText)
            
            usernameLbl.attributedText = attributedUsernameText
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
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
         detailVC.user = user
         
         self.controller.navigationController?.pushViewController(detailVC, animated: true)
     }    
}

 */
