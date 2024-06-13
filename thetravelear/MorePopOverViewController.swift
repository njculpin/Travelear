//
//  MorePopOverViewController.swift
//
//
//  Created by Nicholas Culpin on 1/19/17.
//
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import FirebaseAuth
import FirebaseFirestore
import Social
import CoreData


class MorePopOverViewController: TravelearViewController {
    
    lazy var trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray
        divider.alpha = 0.5
        return divider
    }()
    
    lazy var addToFavoritesButton: UIButton = {
        let sb = UIButton()
        sb.setImage(UIImage(named: "addFav"), for: .normal)
        sb.addTarget(self, action: #selector(addToFavoritesButtonPressed), for: .touchUpInside)
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    lazy var addToNextButton: UIButton = {
        let sb = UIButton()
        sb.setImage(UIImage(named: "addQueue"), for: .normal)
        sb.addTarget(self, action: #selector(addToNextButtonPressed), for: .touchUpInside)
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    lazy var shareButton: UIButton = {
        let sb = UIButton()
        sb.setImage(UIImage(named: "share"), for: .normal)
        sb.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    lazy var popOverTitleLabel = TravelearLabel()
    
    lazy var cancelButton: UIButton = {
        let sb = UIButton()
        let image = UIImage(named: "min-button") as UIImage?
        sb.setImage(image, for: .normal)
        sb.contentHorizontalAlignment = .center
        sb.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        sb.isAccessibilityElement = true
        sb.accessibilityLabel = "Minimize"
        return sb
    }()
    
    lazy var titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.spacing = 0
        stack.distribution = UIStackView.Distribution.equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.fillProportionally
        stack.spacing = 4
        stack.alignment = UIStackView.Alignment.leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = UIColor.white
        return stack
    }()
    
    lazy var shareStackBar: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    lazy var trackDescription = TravelearLabel()
    
    var creatorName = String()
    var creatorImage = String()
    var isPublic = Bool()
    var author = String()
    var duration = String()
    var file = String()
    var image = String()
    var latitude = Double()
    var longitude = Double()
    var location = String()
    var id = String()
    var name = String()
    var recorded = Date()
    var tags = String()
    var timestamp = Date()
    var isWorld = Bool()
    var isSleep = Bool()
    var isMonetized = Bool()
    
    let db = Firestore.firestore()

    // Share from Dynamic Link
    var longLink: URL?
    var shortLink: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        self.view.backgroundColor = .white
        
        popOverTitleLabel.font = UIFont.TravDemiLarge()
        trackDescription.font = UIFont.TravRegular()
    }
    
    func setUpViews(){
        self.view.addSubview(popOverTitleLabel)
        self.view.addSubview(cancelButton)
        self.view.addSubview(trackImageView)
        self.view.addSubview(shareStackBar)
        self.view.addSubview(contentStackView)
        self.view.addSubview(divider)
        shareStackBar.addArrangedSubview(shareButton)
        shareStackBar.addArrangedSubview(addToNextButton)
        shareStackBar.addArrangedSubview(addToFavoritesButton)
        contentStackView.addArrangedSubview(trackDescription)
        
        popOverTitleLabel.numberOfLines = 2
        
        cancelButton.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: popOverTitleLabel.topAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 22, leftConstant: 8, bottomConstant: 0, rightConstant: 22, widthConstant: 44, heightConstant: 44)
        popOverTitleLabel.anchor(nil, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.trackImageView.topAnchor, right: cancelButton.rightAnchor, topConstant: 22, leftConstant: 22, bottomConstant: 16, rightConstant: 22, widthConstant: 0, heightConstant: 0)
        trackImageView.anchor(nil, left: self.view.leftAnchor, bottom: shareStackBar.topAnchor, right: self.view.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
        shareStackBar.anchor(nil, left: self.view.leftAnchor, bottom: divider.topAnchor, right: self.view.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        divider.anchor(nil, left: self.view.leftAnchor, bottom: contentStackView.topAnchor, right: self.view.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 16, rightConstant: 0, widthConstant:  0, heightConstant: 0.5)
        contentStackView.anchor(nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 22, leftConstant: 22, bottomConstant: 0, rightConstant: 22, widthConstant: 0, heightConstant: 0)
        
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addToNextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addToFavoritesButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
        let imageURL = URL(string:image)
        DispatchQueue.main.async(execute: {
            self.trackImageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "lockscreen-default"), completed: nil)
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        
        self.trackDescription.text = "\(self.name) was recorded by \(self.creatorName) in \(self.location) on \(dateFormatter.string(from: self.recorded))."

        popOverTitleLabel.text = "\(name)"
        shareButton.accessibilityLabel = "Share \(name)"
        addToFavoritesButton.accessibilityLabel = "Add to Favorites!"
        addToNextButton.accessibilityLabel = "Add to my Trip!"
    }
    
    @objc func shareButtonPressed(){
        
        let params:[String : String] = [
            "ibi": AppConstants.bundleID,
            "isi": AppConstants.appStoreID,
            "efr":"1",
            "si": self.image
        ]
        
        // general link params
        let urlParams = params.compactMap ({ (key,value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        
        guard let link = URL(string:"https://www.thetravelear.com/share/\(self.id)/\(urlParams)") else { return }
        
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: "https://travelear.page.link")
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: AppConstants.bundleID)
        linkBuilder?.iOSParameters?.appStoreID = AppConstants.appStoreID
        linkBuilder?.iOSParameters?.minimumAppVersion = AppConstants.mandatoryVersion
        linkBuilder?.iOSParameters?.fallbackURL = URL(string:AppConstants.bundleID)
        linkBuilder?.iOSParameters?.customScheme = AppConstants.bundleID
        linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder?.socialMetaTagParameters?.title = "listen to \(self.name)"
        linkBuilder?.socialMetaTagParameters?.descriptionText = "Travelear is a 3D Soundscape social library"
        linkBuilder?.socialMetaTagParameters?.imageURL = URL(string:self.image)
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .short
        linkBuilder?.options = options
        linkBuilder?.shorten(completion: { (url, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.showShare(msg: "\(url!.absoluteString)")
        })
    }
    
    func showShare(msg:String){
        let shareSheet = UIActivityViewController(activityItems: [ msg ], applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = self.view
        self.present(shareSheet, animated: true, completion: nil)
        AnalyticsService.logShareEvent(title: self.name, id: self.id)
    }

    // add the track to favorites
    @objc func addToFavoritesButtonPressed() {
        postToFavorites()
    }

    // add the track to play next
    @objc func addToNextButtonPressed() {
        postToQueue()
    }
    
    func postToFavorites(){
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        let entity =
          NSEntityDescription.entity(forEntityName: "FavoriteTrack",
                                     in: managedContext)!
        
        let track = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        track.setValue(creatorName, forKey: "creatorName")
        track.setValue(creatorImage, forKey: "creatorImage")
        track.setValue(isSleep, forKey: "isSleep")
        track.setValue(isWorld, forKey: "isWorld")
        track.setValue(isPublic, forKey: "isPublic")
        track.setValue(author, forKey: "author")
        track.setValue(duration, forKey: "duration")
        track.setValue(file, forKey: "file")
        track.setValue(image, forKey: "image")
        track.setValue(latitude, forKey: "latitude")
        track.setValue(longitude, forKey: "longitude")
        track.setValue(location, forKey: "location")
        track.setValue(id, forKey: "id")
        track.setValue(name, forKeyPath: "name")
        track.setValue(recorded, forKey: "recorded")
        track.setValue(tags, forKey: "tags")
        track.setValue(timestamp, forKey: "timestamp")
        track.setValue(isMonetized, forKey: "isMonetized")
        
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        // SAVE TO FIREBASE
        let user = Auth.auth().currentUser
        let uid = user!.uid
        db.collection("users").document(uid).updateData(["favorites": FieldValue.arrayUnion([id])])
        
        // NOTIFY USER
        giveNotification(name: "Favorites")
        AnalyticsService.postToListEvent(title: self.name, id: self.id, list: "favorites")
        self.dismiss(animated: true, completion: nil)
    }
    
    func postToQueue(){
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
         
         let managedContext =
         appDelegate.persistentContainer.viewContext
         
         let entity =
           NSEntityDescription.entity(forEntityName: "QueueTrack",
                                      in: managedContext)!
         
         let track = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
         
         track.setValue(creatorName, forKey: "creatorName")
         track.setValue(creatorImage, forKey: "creatorImage")
         track.setValue(isSleep, forKey: "isSleep")
         track.setValue(isWorld, forKey: "isWorld")
         track.setValue(isPublic, forKey: "isPublic")
         track.setValue(author, forKey: "author")
         track.setValue(duration, forKey: "duration")
         track.setValue(file, forKey: "file")
         track.setValue(image, forKey: "image")
         track.setValue(latitude, forKey: "latitude")
         track.setValue(longitude, forKey: "longitude")
         track.setValue(location, forKey: "location")
         track.setValue(id, forKey: "id")
         track.setValue(name, forKeyPath: "name")
         track.setValue(recorded, forKey: "recorded")
         track.setValue(tags, forKey: "tags")
         track.setValue(timestamp, forKey: "timestamp")
        track.setValue(isMonetized, forKey: "isMonetized")
         
         do {
           try managedContext.save()
         } catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
         }
         
         // NOTIFY USER
         giveNotification(name: "Trip")
         AnalyticsService.postToListEvent(title: self.name, id: self.id, list: "trip")
         self.dismiss(animated: true, completion: nil)
    }
    
    func giveNotification(name:String){
        let name = ["name":name] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"notifyAdd"), object: nil, userInfo: name)
    }

}

