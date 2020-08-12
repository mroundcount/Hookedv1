//
//  AudioTableViewCell.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/14/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var dataLbl: UILabel!
    
    var audio: Audio!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //modified to remove image
    //Function called from the table view controller
    func configureCell(uid: String, audio: Audio) {
        self.audio = audio
        let titleText = audio.title
        if !titleText.isEmpty {
            titleLbl.isHidden = false
            titleLbl.text = audio.title
        }
        
        let genreText = audio.genre
        if !genreText.isEmpty {
            genreLbl.isHidden = false
            genreLbl.text = audio.genre
        }
        
        //We'll do test styling in here too
        //Time stamp from how long ago the audio file was uploaded
        let date = Date(timeIntervalSince1970: audio.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dataLbl.text = dateString
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
