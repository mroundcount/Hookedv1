//
//  PreferenceTableViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 4/16/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit

class PreferenceTableViewController: UITableViewController {
    
    let genre = ["Rock", "Classical", "Pop"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Like Artists"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(closeDidTapped))
        navigationItem.leftBarButtonItem = close
        
        let save = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveDidTapped))
        navigationItem.rightBarButtonItem = save
    }
    
    @objc func closeDidTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveDidTapped() {
        print("saved")
        navigationController?.popViewController(animated: true)
        
        var dict = Dictionary<String, Any>()
 
        /*
         if genderSegment.selectedSegmentIndex == 0 {
             dict["isMale"] = true
         }
         if genderSegment.selectedSegmentIndex == 1 {
             dict["isMale"] = false
         }
 */
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genre.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = genre[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }   
    }
}
