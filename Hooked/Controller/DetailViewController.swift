//
//  DetailViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/28/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import CoreLocation
import LNPopupController
import AVFoundation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var popupContentController: DemoMusicPlayerController!
    
    var user: User!
    var users: [User] = []
    var audio = [Audio]()
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        observeData()
 
        let backImg = UIImage(named: "close")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backBtn.setImage(backImg, for: UIControl.State.normal)
        backBtn.tintColor = .white
        
        backBtn.layer.cornerRadius = 35/2
        backBtn.clipsToBounds = true
        
        avatar.loadImage(user.profileImageUrl)
   
        avatar.clipsToBounds = true
        let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350)
        avatar.addBlackGradientLayer(frame: frameGradient, colors: [.clear, .black])
        usernameLbl.text = user.username
        if user.age != nil {
            ageLbl.text = " \(user.age!)"
        } else {
            ageLbl.text = ""
        }
        
        if let isMale = user.isMale {
            let genderImgName = (isMale == true) ? "icon-male" : "icon-female"
            genderImage.image = UIImage(named: genderImgName)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            
        } else {
            genderImage.image = UIImage(named: "icon-gender")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        }
        
        genderImage.tintColor = .white
        
        //removing the white menu at the top by hiding the same area.
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        
        popupContentController = storyboard?.instantiateViewController(withIdentifier: "DemoMusicPlayerController") as! DemoMusicPlayerController

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
    
    @IBAction func backBtnDidTap(_ sender: Any) {
        //dismiss scene
        navigationController?.popViewController(animated: true)
    }
    
    func observeData() {
        Api.Audio.pullAudio(artist: user.uid) { (audio) in
            self.audio.append(audio)
            self.sortAudio()
            print("calling audiofile: ")
            print("artist: \(audio.artist)")
            print(audio.title)
            print(audio.genre)
            print(audio.date)
            print(audio.audioUrl)
            print("Observation complete")
        }
        print("username: \(user.username)")
    }
    
    func sortAudio() {
        audio = audio.sorted(by: { $0.date < $1.date })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    /*
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    //which row returns what
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        //Row 1 of cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.imageView?.image = UIImage(named: "phone")
            cell.textLabel?.text = "123456789"
            cell.selectionStyle = .none
            return cell
        //Row 2 of cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.imageView?.image = UIImage(named: "phone")
            cell.textLabel?.text = "Row 2"
            cell.selectionStyle = .none
            return cell
            
            /*
             let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
             cell.imageView?.image = UIImage(named: "map-1")
             if !user.latitude.isEmpty, !user.longitude.isEmpty {
             let location = CLLocation(latitude: CLLocationDegrees(Double(user.latitude)!), longitude: CLLocationDegrees(Double(user.longitude)!))
             let geocoder = CLGeocoder()
             geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
             if error == nil, let placemarksArray = placemarks, placemarksArray.count > 0 {
             if let placemark = placemarksArray.last {
             var text = ""
             if let thoroughFare = placemark.thoroughfare {
             text = "\(thoroughFare)"
             cell.textLabel?.text = text
             }
             if let postalCode = placemark.postalCode {
             text = text + " " + postalCode
             cell.textLabel?.text = text
             }
             if let locality = placemark.locality {
             text = text + " "  + locality
             cell.textLabel?.text = text
             }
             if let country = placemark.country {
             text = text + " "  + country
             cell.textLabel?.text = text
             }
             }
             }
             }
             }
             cell.selectionStyle = .none
             
             return cell
             */
        //row three of cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = "Row 3"
            cell.selectionStyle = .none
            
            return cell
            
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = "Row 4"
            cell.selectionStyle = .none
            
            
            /*
             let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapTableViewCell
             cell.controller = self
             if !user.latitude.isEmpty, !user.longitude.isEmpty {
             let location = CLLocation(latitude: CLLocationDegrees(Double(user.latitude)!), longitude: CLLocationDegrees(Double(user.longitude)!))
             cell.configure(location: location)
             }
             cell.selectionStyle = .none
             */
        default:
            break
        }
        
        return UITableViewCell()
    }
    //hard code in the row size to make it bigger. In the demo this is where the mapping info goes.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 300
        }
        return 44
    }
     */
}

