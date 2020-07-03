//
//  Likes.swift
//  Hooked
//
//  Created by Michael Roundcount on 4/19/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import UIKit
//each instance of this call holds an instance of a user from the database
class Likes {
    var uid: String
    var like: Bool?

    //teaching the class to create a new instance
    //We create an initializer. Assign each parameter to an instance variable
    init(uid: String, like: Bool) {
        self.uid = uid
        self.like = like

    }
    
/*
    //The method that excepts the dictionary and turns it into the users varaible
    static func transformUser(dict: [String: Any]) -> Like? {
        //use gaurd to unwrap the data from the dictionary
        let uid = dict["uid"] as? String else {
            return nil
        }
        //assign all of the unwrapped data to the instnce user, and return the full user at the end
        //let user = User (uid: uid, username: username, email: email, profileImageUrl: profileImageUrl, status: status)
        let like = like (uid: uid, like: like)
        
        //edit later
        if let isMale = dict["isMale"] as? Bool {
            user.isMale = isMale
        }
        
        return like
    }
}


extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
 */
}
