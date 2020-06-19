//
//  DetailViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/28/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    var users: [User] = []
    
    // var isMatch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendBtn.layer.cornerRadius = 5
        sendBtn.clipsToBounds = true
        
        let backImg = UIImage(named: "close")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backBtn.setImage(backImg, for: UIControl.State.normal)
        backBtn.tintColor = .white
        
        backBtn.layer.cornerRadius = 35/2
        backBtn.clipsToBounds = true
        
        avatar.loadImage(user.profileImageUrl)
   
        avatar.clipsToBounds = true
        //avatar.image = user.profileImag
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
    
}


extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
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
}

