//
//  Card.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/30/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import CoreLocation

class Card: UIView {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var nopeView: UIView!
    @IBOutlet weak var nopeLbl: UILabel!
    
    var controller: RadarViewController!
    
    //extracting info from the user object
    var user: User! {
        //pass the user object the array and create a new card, then append the card to the cards array
        didSet {
            photo.loadImage(user.profileImageUrl) { (image) in
                self.user.profileImage = image
            }
            //using attributed string from earlier lessons to combine the username and age
            let attributedUsernameText = NSMutableAttributedString(string: "\(user.username)  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30),
                                                                                                              NSAttributedString.Key.foregroundColor : UIColor.white                                                                     ])
            //the age can be nil so be sure to check it.
            var age = ""
            if let ageValue = user.age {
                age = String(ageValue)
            }
            let attributedAgeText = NSMutableAttributedString(string: age, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22),
                                                                                        NSAttributedString.Key.foregroundColor : UIColor.white                                                                     ])
            attributedUsernameText.append(attributedAgeText)
            
            usernameLbl.attributedText = attributedUsernameText
            
            //checking for user location so it can be displayed on the card.
            if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
                let currentLocation:CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
                if !user.latitude.isEmpty && !user.longitude.isEmpty {
                    
                    let userLoc = CLLocation(latitude: Double(user.latitude)! , longitude: Double(user.longitude)!)
                    let distanceInKM: CLLocationDistance = userLoc.distance(from: currentLocation) / 1000
                    // let kmIntoMiles = distanceInKM * 0.6214
                    locationLbl.text = "\(Int(distanceInKM)) Km away"
                } else {
                    locationLbl.text = ""
                }
            }
        }
    }
    
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
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
        detailVC.user = user
        
        self.controller.navigationController?.pushViewController(detailVC, animated: true)
         */
    }
    
}
