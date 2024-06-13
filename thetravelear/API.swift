//
//  API.swift
//  Travelear
//
//  Created by Nicholas Culpin on 8/25/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

class API {
    
    static func download(completion: @escaping ([Track]) -> Void) {
        var tracks = [Track]()
        let db = Firestore.firestore()
        if Auth.auth().currentUser != nil {
            db.collection("tracks-published").order(by: "timestamp", descending: true).getDocuments() { (documents, err) in
                if let documents = documents {
                    for document in documents.documents {
                        
                        let creatorName = document.get("creatorName") as! String
                        let creatorImage = document.get("creatorImage") as! String
                        let isMonetized = document.get("isMonetized") as! Bool
                        let isSleep = document.get("isSleep") as! Bool
                        let isWorld = document.get("isWorld") as! Bool
                        let isPublic = document.get("isPublic") as! Bool
                        let author = document.get("author") as! String
                        let duration = convertStringDurationToDouble(duration: document.get("duration") as! String)
                        let file = document.get("file") as! String
                        let image = document.get("image") as! String
                        let latitude = document.get("latitude") as! Double
                        let longitude = document.get("longitude") as! Double
                        let location = document.get("location") as! String
                        let id = document.get("id") as! String
                        let name = document.get("name") as! String
                        let recorded = document.get("recorded") as! Timestamp
                        let tags = document.get("tags") as! String
                        let timestamp = document.get("timestamp") as! Timestamp
                        let recordedAsDate = recorded.dateValue()
                        let timestampAsDate = timestamp.dateValue()
                        
                        if isPublic == true && isWorld == true {
                            let track = Track(creatorName:creatorName, creatorImage:creatorImage, isPublic:isPublic, author:author, duration:duration, file:file, image:image, latitude:latitude, longitude:longitude, location:location, id:id, name:name, recorded:recordedAsDate, tags:tags, timestamp:timestampAsDate, isMonetized:isMonetized, isSleep:isSleep, isWorld:isWorld)
                            tracks.append(track)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
                completion(tracks)
            }
        }
    }
    
    static func getTrack(id:String, completion: @escaping (Track) -> Void){
        if Auth.auth().currentUser != nil {
            let db = Firestore.firestore().collection("tracks-published").document(id)
            db.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    let creatorName = document.get("creatorName") as! String
                    let creatorImage = document.get("creatorImage") as! String
                    let isMonetized = document.get("isMonetized") as! Bool
                    let isSleep = document.get("isSleep") as! Bool
                    let isWorld = document.get("isWorld") as! Bool
                    let isPublic = document.get("isPublic") as! Bool
                    let author = document.get("author") as! String
                    let duration = convertStringDurationToDouble(duration: document.get("duration") as! String)
                    let file = document.get("file") as! String
                    let image = document.get("image") as! String
                    let latitude = document.get("latitude") as! Double
                    let longitude = document.get("longitude") as! Double
                    let location = document.get("location") as! String
                    let id = document.get("id") as! String
                    let name = document.get("name") as! String
                    let recorded = document.get("recorded") as! Timestamp
                    let tags = document.get("tags") as! String
                    let timestamp = document.get("timestamp") as! Timestamp
                    let recordedAsDate = recorded.dateValue()
                    let timestampAsDate = timestamp.dateValue()
                    
                    let track = Track(creatorName:creatorName, creatorImage:creatorImage, isPublic:isPublic, author:author, duration:duration, file:file, image:image, latitude:latitude, longitude:longitude, location:location, id:id, name:name, recorded:recordedAsDate, tags:tags, timestamp:timestampAsDate,isMonetized: isMonetized, isSleep:isSleep, isWorld:isWorld)
                    
                    completion(track)
                }
            }
        }
    }
    
    // TODO: Get this for profile Images
    static func getCreator(authorID:String, completion: @escaping (Creator) -> Void){
        if Auth.auth().currentUser != nil {
            let db = Firestore.firestore().collection("creators").document(authorID)
            db.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    let email = document.get("email") as! String
                    let firstName = document.get("firstName") as! String
                    let lastName = document.get("lastName") as! String
                    let bio = document.get("bio") as! String
                    let location = document.get("location") as! String
                    let profileImage = document.get("profileImage") as? String ?? ""
                    let id = document.get("id") as! String
                    let joined = document.get("joined") as! Timestamp
                    let joinedAsDate = joined.dateValue()
                    let status = document.get("status") as! Bool
                    
                    let creator = Creator(email: email, firstName: firstName, lastName: lastName, bio: bio, location: location, profileImage: profileImage, id: id, status: status, joined: joinedAsDate)
                    
                    completion(creator)
                }
            }
        }
    }
    
    static func getUser(completion: @escaping (User) -> Void){
        if Auth.auth().currentUser != nil {
            let db = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            db.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    let email = document.get("email") as! String
                    let firstName = document.get("firstName") as! String
                    let lastName = document.get("lastName") as! String
                    let bio = document.get("bio") as! String
                    let location = document.get("location") as! String
                    let profileImage = document.get("profileImage") as? String ?? ""
                    let id = document.get("id") as! String
                    let joined = document.get("joined") as! Timestamp
                    let vender = document.get("vender") as? String ?? ""
                    let subscription_active = document.get("subscription_active") as? String ?? ""
                    let subscription_period_start = document.get("subscription_period_start") as? Timestamp ?? Timestamp()
                    let subscription_period_end = document.get("subscription_period_end") as? Timestamp ?? Timestamp()
                    let subscription_nickname = document.get("subscription_nickname") as? String ?? ""
                    let favorites = document.get("favorites") as? [String] ?? [""]
                    
                    let user = User(email: email, firstName: firstName, lastName: lastName, bio: bio, location: location, profileImage: profileImage, id: id, joined: joined.dateValue(),vender: vender, subscription_active: subscription_active, subscription_period_start: subscription_period_start.dateValue(), subscription_period_end: subscription_period_end.dateValue(), subscription_nickname: subscription_nickname, favorites: favorites)
                    completion(user)
                } else {
                    print("no user")
                }
            }
        }
    }
    
    static func saveFavorites(){
        let db = Firestore.firestore()
        if Auth.auth().currentUser != nil {
            db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let favorites = document.get("favorites") as? [String] else { return }
                    for eventID in favorites {
                        db.collection("tracks-published").whereField("id", isEqualTo: eventID).getDocuments { (documents, error) in
                            if let documents = documents {
                                for document in documents.documents {
                                    
                                    let creatorName = document.get("creatorName") as! String
                                    let creatorImage = document.get("creatorImage") as! String
                                    let isMonetized = document.get("isMonetized") as! Bool
                                    let isSleep = document.get("isSleep") as! Bool
                                    let isWorld = document.get("isWorld") as! Bool
                                    let isPublic = document.get("isPublic") as! Bool
                                    let author = document.get("author") as! String
                                    let duration = document.get("duration") as! String
                                    let file = document.get("file") as! String
                                    let image = document.get("image") as! String
                                    let latitude = document.get("latitude") as! Double
                                    let longitude = document.get("longitude") as! Double
                                    let location = document.get("location") as! String
                                    let id = document.get("id") as! String
                                    let name = document.get("name") as! String
                                    let recorded = document.get("recorded") as! Timestamp
                                    let tags = document.get("tags") as! String
                                    let timestamp = document.get("timestamp") as! Timestamp
                                    let recordedAsDate = recorded.dateValue()
                                    let timestampAsDate = timestamp.dateValue()
                                    
                                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                                                                        
                                    if checkIfEventExists(id: id) != true {
                                        
                                        let managedContext = appDelegate.persistentContainer.viewContext
                                        
                                        let entity = NSEntityDescription.entity(forEntityName: "FavoriteTrack",
                                                                     in: managedContext)!
                                        
                                        let favoriteEvent = NSManagedObject(entity: entity, insertInto: managedContext)
                                        
                                        favoriteEvent.setValue(name, forKeyPath: "name")
                                        favoriteEvent.setValue(file, forKey: "file")
                                        favoriteEvent.setValue(image, forKey: "image")
                                        favoriteEvent.setValue(duration, forKey: "duration")
                                        favoriteEvent.setValue(creatorName, forKey: "creatorName")
                                        favoriteEvent.setValue(creatorImage, forKey: "creatorImage")
                                        favoriteEvent.setValue(isSleep, forKey: "isSleep")
                                        favoriteEvent.setValue(isWorld, forKey: "isWorld")
                                        favoriteEvent.setValue(isPublic, forKey: "isPublic")
                                        favoriteEvent.setValue(author, forKey: "author")
                                        favoriteEvent.setValue(id, forKey: "id")
                                        favoriteEvent.setValue(author, forKey: "author")
                                        favoriteEvent.setValue(creatorName, forKey: "creatorName")
                                        favoriteEvent.setValue(creatorImage, forKey: "creatorImage")
                                        favoriteEvent.setValue(isMonetized, forKey: "isMonetized")
                                        favoriteEvent.setValue(isSleep, forKey: "isSleep")
                                        favoriteEvent.setValue(isWorld, forKey: "isWorld")
                                        favoriteEvent.setValue(isPublic, forKey: "isPublic")
                                        favoriteEvent.setValue(latitude, forKey: "latitude")
                                        favoriteEvent.setValue(longitude, forKey: "longitude")
                                        favoriteEvent.setValue(location, forKey: "location")
                                        favoriteEvent.setValue(recordedAsDate, forKey: "recorded")
                                        favoriteEvent.setValue(tags, forKey: "tags")
                                        favoriteEvent.setValue(timestampAsDate, forKey: "timestamp")
                                        
                                        do {
                                          try managedContext.save()
                                        } catch let error as NSError {
                                          print("Could not save. \(error), \(error.userInfo)")
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func saveFavorite(track:Track){
                
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FavoriteTrack", in: managedContext)!
        let favoriteEvent = NSManagedObject(entity: entity, insertInto: managedContext)

        favoriteEvent.setValue(track.name, forKeyPath: "name")
        favoriteEvent.setValue(track.file, forKey: "file")
        favoriteEvent.setValue(track.image, forKey: "image")
        favoriteEvent.setValue(track.duration, forKey: "duration")
        favoriteEvent.setValue(track.creatorName, forKey: "creatorName")
        favoriteEvent.setValue(track.creatorImage, forKey: "creatorImage")
        favoriteEvent.setValue(track.isSleep, forKey: "isSleep")
        favoriteEvent.setValue(track.isWorld, forKey: "isWorld")
        favoriteEvent.setValue(track.isPublic, forKey: "isPublic")
        favoriteEvent.setValue(track.author, forKey: "author")
        favoriteEvent.setValue(track.id, forKey: "id")
        favoriteEvent.setValue(track.author, forKey: "author")
        favoriteEvent.setValue(track.creatorName, forKey: "creatorName")
        favoriteEvent.setValue(track.creatorImage, forKey: "creatorImage")
        favoriteEvent.setValue(track.isMonetized, forKey: "isMonetized")
        favoriteEvent.setValue(track.isSleep, forKey: "isSleep")
        favoriteEvent.setValue(track.isWorld, forKey: "isWorld")
        favoriteEvent.setValue(track.isPublic, forKey: "isPublic")
        favoriteEvent.setValue(track.latitude, forKey: "latitude")
        favoriteEvent.setValue(track.longitude, forKey: "longitude")
        favoriteEvent.setValue(track.location, forKey: "location")
        favoriteEvent.setValue(track.recorded, forKey: "recorded")
        favoriteEvent.setValue(track.tags, forKey: "tags")
        favoriteEvent.setValue(track.timestamp, forKey: "timestamp")
        
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        // SAVE TO FIREBASE
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let uid = user!.uid
        db.collection("users").document(uid).updateData(["favorites": FieldValue.arrayUnion([track.id!])])
        
    }
    
    static func removeFavorite(id: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteTrack")
        fetchRequest.predicate = NSPredicate(format: "id == %@",id)
        var results: [NSManagedObject] = []
        do {
            results = try managedContext.fetch(fetchRequest)
            for i in results {
                managedContext.delete(i)
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    static func checkIfEventExists(id: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteTrack")
        fetchRequest.predicate = NSPredicate(format: "id == %@",id)
        var results: [NSManagedObject] = []
        do {
            results = try (managedContext?.fetch(fetchRequest))!
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
    
    static func savePurchase(identifier: String?, subscription_period_start: Date?, subscription_period_end: Date?){
        let nickname = API.convertProductIDName(identifier: identifier)
        let unique_vendor_identifier = UIDevice.current.identifierForVendor?.uuidString
        let db = Firestore.firestore()
        if Auth.auth().currentUser != nil {
            db.collection("users").document(Auth.auth().currentUser!.uid).updateData([
                "vender":"apple-world",
                "unique_vendor_identifier": unique_vendor_identifier!,
                "subscription_active" : "active",
                "subscription_nickname": nickname,
                "subscription_period_end": subscription_period_end!,
                "subscription_period_start": subscription_period_start!
            ])
            if Date() <= subscription_period_end! {
                let defaults = UserDefaults.standard
                if defaults.isPurchased() != true {
                    defaults.set(true, forKey:"isPurchased")
                    defaults.synchronize()
                }
            } else {
                API.expiredPurchase()
            }
        }
    }
    
    static func convertProductIDName(identifier:String?) -> String {
        var nickname = String()
        switch (identifier) {
            case "xxx":
                nickname = "One Month"
            case "xxx":
                nickname = "Six Month"
            case "xxx":
                nickname = "Twelve Month"
        default:
            nickname = " "
        }
        return nickname
    }
    
    static func expiredPurchase(){
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData([
            "subscription_active" : "expired",
        ])
        Alerts.showErrorBanner("Your membership is expired")
        let defaults = UserDefaults.standard
        defaults.set(false, forKey:"isPurchased")
        defaults.synchronize()
    }
    
    static func convertStringDurationToDouble(duration:String) -> Double{
        var converted: Double
        let split = duration.components(separatedBy: ":")
        let minutes = Int(split[0])! / 60
        let seconds = Int(split[0])! % 60
        converted = Double(minutes) + Double(seconds)
        return converted
    }
    
}
