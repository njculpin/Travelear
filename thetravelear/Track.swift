//
//  Track.swift
//  Travelear
//
//  Created by Nicholas Culpin on 8/25/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import Foundation

class Track: NSObject, NSCoding , Decodable {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(creatorName ?? "", forKey: "creatorName")
        aCoder.encode(creatorImage ?? "", forKey: "creatorImage")
        aCoder.encode(isMonetized ?? "", forKey: "isMonetized")
        aCoder.encode(isSleep ?? "", forKey: "isSleep")
        aCoder.encode(isWorld ?? "", forKey: "isWorld")
        aCoder.encode(isPublic ?? "", forKey: "isPublic")
        aCoder.encode(author ?? "", forKey: "author")
        aCoder.encode(duration ?? "", forKey: "duration")
        aCoder.encode(file ?? "", forKey: "file")
        aCoder.encode(image ?? "", forKey: "image")
        aCoder.encode(latitude ?? "", forKey: "latitude")
        aCoder.encode(longitude ?? "", forKey: "longitude")
        aCoder.encode(location ?? "", forKey: "location")
        aCoder.encode(id ?? "", forKey: "id")
        aCoder.encode(name ?? "", forKey: "name")
        aCoder.encode(recorded ?? "", forKey: "recorded")
        aCoder.encode(tags ?? "", forKey: "tags")
        aCoder.encode(timestamp ?? "", forKey: "timestamp")
    }
    
    init(creatorName:String, creatorImage:String, isPublic:Bool,author:String, duration:Double, file:String, image:String, latitude:Double, longitude:Double, location: String, id:String, name:String, recorded:Date, tags:String, timestamp:Date, isMonetized:Bool, isSleep:Bool, isWorld:Bool) {
        self.creatorName = creatorName
        self.creatorImage = creatorImage
        self.isMonetized = isMonetized
        self.isSleep = isSleep
        self.isWorld = isWorld
        self.isPublic = isPublic
        self.author = author
        self.duration = duration
        self.file = file
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
        self.id = id
        self.name = name
        self.recorded = recorded
        self.tags = tags
        self.timestamp = timestamp
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.creatorName = aDecoder.decodeObject(forKey: "creatorName") as? String
        self.creatorImage = aDecoder.decodeObject(forKey: "creatorImage") as? String
        self.isMonetized = aDecoder.decodeObject(forKey: "isMonetized") as? Bool
        self.isSleep = aDecoder.decodeObject(forKey: "isSleep") as? Bool
        self.isWorld = aDecoder.decodeObject(forKey: "isWorld") as? Bool
        self.isPublic = aDecoder.decodeObject(forKey: "isPublic") as? Bool
        self.author = aDecoder.decodeObject(forKey: "author") as? String
        self.duration = aDecoder.decodeObject(forKey: "duration") as? Double
        self.file = aDecoder.decodeObject(forKey: "file") as? String
        self.image = aDecoder.decodeObject(forKey: "image") as? String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as? Double
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as? Double
        self.location = aDecoder.decodeObject(forKey: "location") as? String
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.recorded = aDecoder.decodeObject(forKey: "recorded") as? Date
        self.tags = aDecoder.decodeObject(forKey: "tags") as? String
        self.timestamp = aDecoder.decodeObject(forKey: "timestamp") as? Date
    }
    
    var creatorName: String?
    var creatorImage: String?
    var isMonetized: Bool?
    var isSleep: Bool?
    var isWorld: Bool?
    var isPublic: Bool?
    var author: String?
    var duration: Double?
    var file: String?
    var image: String?
    var latitude: Double?
    var longitude: Double?
    var location: String?
    var id: String?
    var name: String?
    var recorded: Date?
    var tags: String?
    var timestamp: Date?
    
}

