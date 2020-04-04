//
//  MessagesTableViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/7/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    //getting up the navigation to go to the swipe page
    func setupNavigationBar() {

       let radarItem = UIBarButtonItem(image: UIImage(named: "icon-radar"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(radarItemDidTap))
       self.navigationItem.rightBarButtonItem = radarItem
       }
    
    //the swipe page navigation
    @objc func radarItemDidTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let radarVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_RADAR) as! RadarViewController
        
        self.navigationController?.pushViewController(radarVC, animated: true)
    }

    

    @IBAction func logoutAction(_ sender: Any) {
        Api.User.logOut()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}
