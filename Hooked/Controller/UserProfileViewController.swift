//
//  UserProfileViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/12/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import LNPopupController
import AVFoundation

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var popupContentController: DemoMusicPlayerController!
    
    var user: User!
    var users: [User] = []
    var audio = [Audio]()
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeData()
 
        uploadBtn.layer.cornerRadius = 5
        uploadBtn.clipsToBounds = true
        
        avatar.clipsToBounds = true
        let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350)
        avatar.addBlackGradientLayer(frame: frameGradient, colors: [.clear, .black])
        
        //removing the white menu at the top by hiding the same area.
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        
        popupContentController = storyboard?.instantiateViewController(withIdentifier: "DemoMusicPlayerController") as! DemoMusicPlayerController

    }
    
    @IBAction func uploadBtnDidPress(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_UPLOAD) as! UploadTableViewController
        self.navigationController?.pushViewController(usersAroundVC, animated: true)
    }
    
    @IBAction func optionsBtnDidPress(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_EDIT_PROFILE) as! ProfileTableViewController
        self.navigationController?.pushViewController(usersAroundVC, animated: true)
    }
    
    
    func observeData() {
        //fetching current user data
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            self.usernameLbl.text = user.username
            self.avatar.loadImage(user.profileImageUrl)
            //adding age and genedner to the user model. These are editable and push to the database
            if let age = user.age {
                self.ageLbl.text = "\(age)"
            } else {
                self.ageLbl.text = "Optional"
            }
        }
        Api.Audio.pullAudio(artist: Api.User.currentUserId) { (audio) in
            self.audio.append(audio)
            self.sortAudio()
            print("calling audiofile: ")
            print(audio.artist)
            print(audio.title)
            print(audio.genre)
            print(audio.date)
            print(audio.audioUrl)
            print("Observation complete")
        }
    }
    
    func sortAudio() {
        audio = audio.sorted(by: { $0.date < $1.date })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //Hide the navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    //unhide the navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}


extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audio.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell") as! AudioTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
        cell.configureCell(uid: Api.User.currentUserId, audio: audio[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AudioTableViewCell
        print(cell.audio.title)
        
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                print("caught ya 2")
                //audioPlayer.stop()
            } else {
                print("OOOOOOOOOOOPPPPPS")
            }
        }
        
        
        popupContentController.songTitle = cell.audio.title
        popupContentController.artistName = cell.audio.artist

        popupContentController.downloadFile(audio: audio[indexPath.row])

        
        popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
        tabBarController?.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString("Dismiss Now Playing Screen", comment: "")
        
        #if targetEnvironment(macCatalyst)
        tabBarController?.popupBar.inheritsVisualStyleFromDockingView = true
        #endif
        
        tabBarController?.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
        
        if #available(iOS 13.0, *) {
            tabBarController?.popupBar.tintColor = UIColor.label
        } else {
            //tabBarController?.popupBar.tintColor = UIColor(white: 38.0 / 255.0, alpha: 1.0)
            tabBarController?.popupBar.tintColor = UIColor(red: 160, green: 160, blue: 160, alpha: 1)
        }
                
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        //copy this and add the variables in the return with "delete
        let delete = UITableViewRowAction(style: .normal, title: "      Delete     ") { action, index in
            let cell = tableView.cellForRow(at: editActionsForRowAt) as? AudioTableViewCell
            print("Removed \(cell?.audio.title)")
        }
        delete.backgroundColor = .red
        return [delete]
    }
}
