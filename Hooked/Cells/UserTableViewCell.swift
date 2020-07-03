//
//  UserTableViewCell.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/7/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import Firebase
protocol UpdateTableProtocol {
    func reloadData()
}

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    var user: User!
    var delegate: UpdateTableProtocol!
    var controller: PeopleTableViewController!

    
    override func awakeFromNib() {
    super.awakeFromNib()
        //half of the height and width (60 in this case)
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        avatar.contentMode = . scaleAspectFill
    }
    
    //Refer to the userAPI
    func loadData(_ user: User) {
        self.user = user
        //self.ageLbl.text = user.username
        self.usernameLbl.text = user.username
        self.statusLbl.text = user.status
        //passing the url to the method
        self.avatar.loadImage(user.profileImageUrl)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
