//
//  NewMatchTableViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/31/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit

class NewMatchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var users: [User] = []
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    var searchResults: [User] = []
    var controller: NewMatchTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSearchBarController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observeUsers()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Liked Artists"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        /*
         The following code is for set up the navigations to test pages that are not usable for a published application
         
         let location = UIBarButtonItem(image: UIImage(named: "icon-location"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(locationDidTapped))
         navigationItem.leftBarButtonItem = location
         
         let chat = UIBarButtonItem(image: UIImage(named: "mic"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(chatDidTapped))
         navigationItem.rightBarButtonItem = chat
         
         let match = UIBarButtonItem(image: UIImage(named: "icon-radar"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(matchDidTapped))
         //navigationItem.rightBarButtonItem = match
         */
    }
    /*
     @objc func locationDidTapped() {
     let storyboard = UIStoryboard(name: "Main", bundle: nil)
     let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_USER_AROUND) as! UsersAroundViewController
     self.navigationController?.pushViewController(usersAroundVC, animated: true)
     }
     
     @objc func chatDidTapped() {
     let storyboard = UIStoryboard(name: "Main", bundle: nil)
     let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
     self.navigationController?.pushViewController(usersAroundVC, animated: true)
     }
     
     @objc func matchDidTapped() {
     let storyboard = UIStoryboard(name: "Main", bundle: nil)
     let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_PEOPLE) as! PeopleTableViewController
     self.navigationController?.pushViewController(usersAroundVC, animated: true)
     }
     */
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
        searchResults = self.users.filter {
            return $0.username.lowercased().range(of: searchText) != nil
        }
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
    }
    
    func observeUsers() {
        //returns all users in the "newMatch" database. Records are only written when two users like each other.
        /*Api.User.observeNewMatch { (user) in
         self.users.append(user)
         self.tableView.reloadData()
         } */
        self.users.removeAll()
        //returns all users in the "likes" database.
        Api.User.observeNewLike { (user) in
            self.users.append(user)
            self.tableView.reloadData()
            print(user.username)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchResults.count : self.users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS, for: indexPath) as! UserTableViewCell
        let user = searchController.isActive ? searchResults[indexPath.row] : users[indexPath.row]
        cell.delegate = self
        cell.loadData(user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
            detailVC.user = cell.user
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
//we can not use the same cell class as "people"
extension NewMatchTableViewController: UpdateTableProtocol {
    func reloadData() {
        self.tableView.reloadData()
    }
}
