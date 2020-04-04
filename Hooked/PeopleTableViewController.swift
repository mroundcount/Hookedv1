//
//  PeopleTableViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/7/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit

//add in the UISearchResultsUpdating class
class PeopleTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var users: [User] = []
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    //search thru the array of users
    var searchResults: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //testing the root url and the user reference. The user reference is where we'll query from
        //print(Ref().databaseRoot.ref.description())
        //print(Ref().databaseUsers.ref.description())
        setupSearchBarController()
        setupNavigationBar()
        observeUsers()
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
    
    func setupNavigationBar() {
        //title and styling for the navigation bar
        navigationItem.title = "People"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let location = UIBarButtonItem(image: UIImage(named: "icon-location"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(locationDidTapped))
        navigationItem.leftBarButtonItem = location
    }
    
   @objc func locationDidTapped() {
       // switch to UsersAroundVC
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_USER_AROUND) as! UsersAroundViewController
       self.navigationController?.pushViewController(usersAroundVC, animated: true)
   }
    
    func observeUsers() {
        //returns a snapshot of each user
        Api.User.observeUsers { (user) in
            //each time we extract the data and convert it to a user object we append the extracted user info to the array 'user' which is declared at the top
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //print(searchController.searchBar.text) allows you to see the real time search in the console for testing
        if searchController.searchBar.text == nil || searchController.searchBar.text!.isEmpty {
            view.endEditing(true)
        } else {
            //once we have the search convert it to lower case
            let textLowercased = searchController.searchBar.text!.lowercased()
            filerContent(for: textLowercased)
        }
        tableView.reloadData()
    }
    //loop over the user array and return a new array with the filtered users
    func filerContent(for searchText: String) {
        searchResults = self.users.filter {
            return $0.username.lowercased().range(of: searchText) != nil
        }
    }

    // MARK: - Table view data source
    //how many rows are are returning depending on if the search is active or now
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults.count
        } else {
            return self.users.count
        }
        //short hand for the same method using the ternerie (sp?) conditional operator
        //return searchController.isActive ? searchResults.count : self.users.count
    }
    //configure a cell for the tableview. Requests a cell form the table view and reuses them as the user scrolls
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS, for: indexPath) as! UserTableViewCell
        
        //short handed version of the same if logic above
        let user = searchController.isActive ? searchResults[indexPath.row] : users[indexPath.row]
        //display the data encoded in each element of the user array
        cell.delegate = self
        cell.loadData(user)
        
        return cell
    }
    //hard coding in the size of the cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    //my experiment to navigate to the profile of a user tapped..... incomplete
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
                  //detailVC.user = cell.user
               
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
 */

}

extension PeopleTableViewController: UpdateTableProtocol {
    func reloadData() {
        self.tableView.reloadData()
    }
}
