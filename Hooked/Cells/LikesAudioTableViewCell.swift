//
//  LikesAudioTableViewCell.swift
//  Hooked
//
//  Created by Michael Roundcount on 7/29/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit

class LikesAudioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    
    var audio: Audio!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        avatar.contentMode = . scaleAspectFill
    }
 
    //Function called from the table view controller
    func configureCell(audio: Audio) {
        self.audio = audio
        Api.User.getUserInforSingleEvent(uid: audio.artist) { (user) in
            self.artistLbl.text = user.username
            self.avatar.loadImage(user.profileImageUrl)
        }
        self.titleLbl.text = audio.title

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    


}
