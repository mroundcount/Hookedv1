//
//  UserAroundCollectionViewCell.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/26/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class UserAroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    var user: User!
    var controller: UsersAroundViewController!
    
    override func awakeFromNib() {
         super.awakeFromNib()
     }
    
    func loadData(_ user: User) {

        self.user = user
        self.ageLbl.text = user.username        
        self.avatar.loadImage(user.profileImageUrl) { (image) in
          user.profileImage = image
        }
        /*
        if let age = user.age {
            self.ageLbl.text = "\(age)"
        } else {
            self.ageLbl.text = ""
        }
        */
    }
    //manage the business logic of observer methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let refUser = Ref().databaseSpecificUser(uid: self.user.uid)

    }
}
