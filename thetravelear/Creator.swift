//
//  Creator.swift
//  Travelear
//
//  Created by Nick Culpin on 2/1/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation
import Firebase

class Creator: NSObject, NSCoding , Decodable {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email ?? "", forKey: "email")
        aCoder.encode(firstName ?? "", forKey: "firstName")
        aCoder.encode(lastName ?? "", forKey: "lastName")
        aCoder.encode(bio ?? "", forKey: "bio")
        aCoder.encode(profileImage ?? "", forKey: "profileImage")
        aCoder.encode(id ?? "", forKey: "id")
        aCoder.encode(status ?? "", forKey: "status")
        aCoder.encode(joined ?? "", forKey: "joined")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        self.lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        self.bio = aDecoder.decodeObject(forKey: "bio") as? String
        self.location = aDecoder.decodeObject(forKey: "location") as? String
        self.profileImage = aDecoder.decodeObject(forKey: "profileImage") as? String
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.status = aDecoder.decodeObject(forKey: "status") as? Bool
        self.joined = aDecoder.decodeObject(forKey: "joined") as? Date
    }
    
    init(email:String, firstName: String, lastName: String, bio:String, location:String, profileImage:String, id:String, status:Bool?, joined: Date) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.location = location
        self.profileImage = profileImage
        self.id = id
        self.status = status
        self.joined = joined
    }
    
    var email: String?
    var firstName: String?
    var lastName: String?
    var bio: String?
    var location: String?
    var profileImage: String?
    var id: String?
    var status: Bool?
    var joined: Date?

}

