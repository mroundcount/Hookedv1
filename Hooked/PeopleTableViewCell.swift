//
//  PeopleTableViewCell.swift
//  Hooked
//
//  Created by Michael Roundcount on 4/4/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!

    var user: User!
    var controller: UsersAroundViewController!
    
    override func awakeFromNib() {
         super.awakeFromNib()
     }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

}
