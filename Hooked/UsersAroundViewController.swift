//
//  UsersAroundViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/25/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import GeoFire
import CoreLocation
import FirebaseDatabase
import ProgressHUD

class UsersAroundViewController: UIViewController {

    let mySlider = UISlider()
    let distanceLabel = UILabel()
    var manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    var distance: Double = 500
    var users: [User] = []
    var currentLocation: CLLocation?
    var user: User!
    @IBOutlet weak var mapViewButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupNavigationBar()
        configureLocationManager()
        
        print("end")
        //observeData()
        print("end observe")

    }
    
    func configureLocationManager() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingHeading()
        }
        self.geoFireRef = Ref().databaseGeo
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    //This contains the slider in the navigation bar. No storybaord work to do this
    func setupNavigationBar() {
        title = "Find Users"
        //add the refresh button to resize the slider
        let refresh = UIBarButtonItem(image: UIImage(named: "icon-refresh"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(refreshTapped))
        //customizing the refresh value
        distanceLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        distanceLabel.font = UIFont.systemFont(ofSize: 13)
        distanceLabel.text = "100 km"
        distanceLabel.textColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
        
        let distanceItem = UIBarButtonItem(customView: distanceLabel)
        
        //slider details
        mySlider.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        mySlider.minimumValue = 1
        mySlider.maximumValue = 999
        mySlider.isContinuous = true
        mySlider.value = Float(50)
        mySlider.tintColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
        mySlider.addTarget(self, action: #selector(sliderValueChanged(slider:event:)), for: UIControl.Event.valueChanged)
        //slider value refresh method with appended distance label
        navigationItem.rightBarButtonItems = [refresh, distanceItem]
        navigationItem.titleView = mySlider
    }
    
   //temporary opservation method that returns all users. Geo based observation is commented at the botton of this page. I think the observer itself is the issue. It is looking at the distance on the slider and comparing it to the geo
   func observeData() {
    //clear the user data to prevent duplication
    self.users.removeAll()
       Api.User.observeUsers { (user) in
             self.users.append(user)
           print(user.username)
         }
   }
    
    
    //temporary opservation method that returns all users. Geo based observation is commented at the botton of this page
    func findUsers () {
        
        Api.User.observeUsers { (user) in
            self.users.append(user)
            return
            }
        /*
            if user.isMale == nil {
                return
            }
            switch self.segmentControl.selectedSegmentIndex {
            case 0:
            if user.isMale! {
                self.users.append(user)
            }
            case 1:
            if !user.isMale! {
                self.users.append(user)
            }
            case 2:
                self.users.append(user)
            default:
                break
        } */
        self.collectionView.reloadData()
    }
    //Probably will not need to use this
    @IBAction func mapButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.collectionView.reloadData()
    }
    
    
    @objc func refreshTapped() {
        self.collectionView.reloadData()
    }
    //update the slider value as we move it. Remember to add the two parameters
    //it can only be used as a filter once we complete the location... See video 73
    @objc func sliderValueChanged(slider: UISlider, event: UIEvent) {
        print(Double(slider.value))
    }
}


extension UsersAroundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
       
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserAroundCollectionViewCell", for: indexPath) as! UserAroundCollectionViewCell
        let user = users[indexPath.item]
        cell.controller = self
        //cell.loadData(user)
        cell.loadData(user, currentLocation: self.currentLocation)
        
        return cell
    }
    
    //navigation to the selevted user's profile
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? UserAroundCollectionViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
            detailVC.user = cell.user
         
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    
    //sizing the cell based on how many we want in a row.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3 - 2, height: view.frame.size.width/3)
    }
    //spacing vertically between between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    //spacing horizontally between between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}



//Delegate methods to handle location and update the current location
extension UsersAroundViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ProgressHUD.showError("\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //user stop udating so the app is more efficiant and does not call the data every time
        manager.stopUpdatingLocation()
        manager.delegate = nil
        //print("didUpdateLocations")
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        
        //print(newCoordinate.latitude)
        //print(newCoordinate.longitude)
        
        self.currentLocation = updatedLocation
        // update location
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.set("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefaults.set("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefaults.synchronize()
        
        //get the current location of the user.
        if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
            //Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([LAT: userLat, LONG: userLong])
            self.geoFire.setLocation(location, forKey: Api.User.currentUserId) { (error) in
                if error == nil {
                    // Find Users
                    self.findUsers()
                }
            }
        }
    }
}




/*
extension UsersAroundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserAroundCollectionViewCell", for: indexPath) as! UserAroundCollectionViewCell
        cell.avatar.image = UIImage(named: "taylor_swift")
        cell.ageLbl.text = "30"
        cell.distanceLbl.text = "23 km"
        
        return cell
    }
}
*/



/*
func findUsers() {
   
   if queryHandle != nil, myQuery != nil {
       myQuery.removeObserver(withFirebaseHandle: queryHandle!)
       myQuery = nil
       queryHandle = nil
   }
   
   guard let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String else {
       return
   }
   
   let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
   self.users.removeAll()
   
   myQuery = geoFire.query(at: location, withRadius: distance)
   
   queryHandle = myQuery.observe(GFEventType.keyEntered) { (key, location) in
     
       if key != Api.User.currentUserId {
           Api.User.getUserInforSingleEvent(uid: key, onSuccess: { (user) in
               if self.users.contains(user) {
                   return
               }
               if user.isMale == nil {
                   return
               }
               switch self.segmentControl.selectedSegmentIndex {
               case 0:
               if user.isMale! {
                   self.users.append(user)
               }
               case 1:
               if !user.isMale! {
                   self.users.append(user)
               }
               case 2:
                   self.users.append(user)
               default:
                   break
               }
               self.collectionView.reloadData()
           })
       }
   }
}
*/
   
