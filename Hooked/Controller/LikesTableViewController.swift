//
//  NewMatchTableViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 7/28/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import LNPopupController
import AVFoundation

class LikesTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var audio: [Audio] = []
    var searchResults: [Audio] = []
    
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    var audioPlayer: AVAudioPlayer!
    var popupContentController: DemoMusicPlayerController!
    var controller: NewMatchTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSearchBarController()
        
        popupContentController = storyboard?.instantiateViewController(withIdentifier: "DemoMusicPlayerController") as! DemoMusicPlayerController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("In new likes view")
        observeAudio()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Liked Songs"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setupSearchBarController() {
        //front end characterists of the searchbar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search users..."
        searchController.searchBar.barTintColor = UIColor.white
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == nil || searchController.searchBar.text!.isEmpty {
            view.endEditing(true)
        } else {
            //once we have the search convert it to lower case
            let textLowercased = searchController.searchBar.text!.lowercased()
            filerContent(for: textLowercased)
        }
        tableView.reloadData()
    }
    
    func filerContent(for searchText: String) {
        searchResults = self.audio.filter {
            return $0.title.lowercased().range(of: searchText) != nil
        }
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
    }
    
    func observeAudio() {
        self.audio.removeAll()
        print("inside observation function")
        Api.Audio.observeNewLike { (audio) in
            self.audio.append(audio)
            self.tableView.reloadData()
            print("Big test of audio... \(audio.title)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return searchController.isActive ? searchResults.count : self.users.count
        return searchController.isActive ? searchResults.count : self.audio.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell") as! AudioTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikesAudioTableViewCell", for: indexPath) as! LikesAudioTableViewCell
        //cell.configureCell(uid: Api.User.currentUserId, audio: audio[indexPath.row])
        cell.configureCell(audio: audio[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LikesAudioTableViewCell
        
        popupContentController.songTitle = cell.audio.title
        
        Api.User.getUserInforSingleEvent(uid: cell.audio.artist) { (user) in
            self.popupContentController.artistName = user.username
            self.popupContentController.albumArt = user.profileImage
            self.popupContentController.albumArtImageView.loadImage(user.profileImageUrl)            
        }
        
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
}
//we can not use the same cell class as "people"
extension LikesTableViewController: UpdateTableProtocol {
    func reloadData() {
        self.tableView.reloadData()
    }
}
