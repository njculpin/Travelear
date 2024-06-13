//
//  User.swift
//  Travelear
//
//  Created by Nicholas Culpin on 8/25/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import Foundation
import Firebase

class User: NSObject, NSCoding , Decodable {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email ?? "", forKey: "email")
        aCoder.encode(firstName ?? "", forKey: "firstName")
        aCoder.encode(lastName ?? "", forKey: "lastName")
        aCoder.encode(bio ?? "", forKey: "bio")
        aCoder.encode(location ?? "", forKey: "location")
        aCoder.encode(profileImage ?? "", forKey: "profileImage")
        aCoder.encode(id ?? "", forKey: "id")
        aCoder.encode(joined ?? "", forKey: "joined")
        aCoder.encode(vender ?? "", forKey: "vender")
        aCoder.encode(subscription_active ?? "", forKey: "subscription_active")
        aCoder.encode(subscription_period_start ?? "", forKey: "subscription_period_start")
        aCoder.encode(subscription_period_end ?? "", forKey: "subscription_period_end")
        aCoder.encode(subscription_nickname ?? "", forKey: "subscription_nickname")
        aCoder.encode(favorites ?? [], forKey: "favorites")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        self.lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        self.bio = aDecoder.decodeObject(forKey: "bio") as? String
        self.location = aDecoder.decodeObject(forKey: "location") as? String
        self.profileImage = aDecoder.decodeObject(forKey: "profileImage") as? String
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.joined = aDecoder.decodeObject(forKey: "joined") as? Date
        self.vender = aDecoder.decodeObject(forKey: "vender") as? String
        self.subscription_active = aDecoder.decodeObject(forKey: "subscription_active") as? String
        self.subscription_period_start = aDecoder.decodeObject(forKey: "subscription_period_start") as? Date
        self.subscription_period_end = aDecoder.decodeObject(forKey: "subscription_period_end") as? Date
        self.subscription_nickname = aDecoder.decodeObject(forKey: "subscription_nickname") as? String
        self.favorites = aDecoder.decodeObject(forKey: "favorites") as? [String]
    }
    
    init(email:String, firstName: String, lastName: String, bio:String, location:String, profileImage:String, id:String, joined:Date, vender: String,subscription_active: String, subscription_period_start: Date, subscription_period_end: Date, subscription_nickname: String, favorites: [String]) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.location = location
        self.profileImage = profileImage
        self.id = id
        self.joined = joined
        self.vender = vender
        self.subscription_active = subscription_active
        self.subscription_period_start = subscription_period_start
        self.subscription_period_end = subscription_period_end
        self.subscription_nickname = subscription_nickname
        self.favorites = favorites
    }
    
    var email: String?
    var firstName: String?
    var lastName: String?
    var bio: String?
    var location: String?
    var profileImage: String?
    var id: String?
    var joined: Date?
    var vender: String?
    var subscription_active: String?
    var subscription_period_start: Date?
    var subscription_period_end: Date?
    var subscription_nickname: String?
    var favorites: [String]?

}
