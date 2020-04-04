//
//  Ref.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/6/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import Firebase


//All of our firebase related references. We'll assign one for every node. This was we do not have to hardcode elsewhere
let REF_USER = "users"
let URL_STORAGE_ROOT = "gs://hooked-217d3.appspot.com"
let STORAGE_PROFILE = "profile"
let PROFILE_IMAGE_URL = "profileImageUrl"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "username"
let STATUS = "status"
let ERROR_EMPTY_PHOTO = "Please choose your profile image"
let ERROR_EMPTY_EMAIL = "Please enter an email address"
let ERROR_EMPTY_USERNAME = "Please enter a username"
let ERROR_EMPTY_PASSWORD = "Please enter a password"
let ERROR_EMPTY_EMAIL_RESET = "Please enter an email address to reset your password"

let SUCCESS_EMAIL_RESET = "We have just resent you a password reset email. Please check your inbox"

let IDENTIFIER_TABBAR = "TabBarVC"
let IDENTIFIER_WELCOME = "WelcomeVC"

let IDENTIFIER_USER_AROUND = "UsersAroundViewController"
let IDENTIFIER_CELL_USERS = "UserTableViewCell"

let REF_GEO = "Geolocs"

let IDENTIFIER_DETAIL = "DetailViewController"

let IDENTIFIER_RADAR = "RadarViewController"
let IDENTIFIER_NEW_MATCH = "NewMatchTableViewController"
let REF_ACTION = "action"

class Ref {
    let databaseRoot: DatabaseReference = Database.database().reference()
    //store the child node in a global variable
    
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    //method for taking a user id as a parameter to get the reference node
    func databaseSpecificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    
    //StorageRoot that is stored in a global variable
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    //the child class in the firebase url
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    //getting access to the user profile reference
    func storageSpecificProfile(uid: String) -> StorageReference {
        //naigiating to the specific user usering uid
        return storageProfile.child(uid)
    }
    
    var databaseGeo: DatabaseReference {
        return databaseRoot.child(REF_GEO)
    }
    
    var databaseAction: DatabaseReference {
        return databaseRoot.child(REF_ACTION)
    }
    
    func databaseActionForUser(uid: String) -> DatabaseReference {
          return databaseAction.child(uid)
      }
    
}


/*
let storageRef = Storage.storage().reference(forURL: "gs://hooked-217d3.appspot.com")
 download the profile image url
let storageProfileRef = storageRef.child("profile").child(authData.user.uid)
*/