//
//  MapViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 12/3/17.
//  Copyright © 2017 thetravelear. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SDWebImage
import MediaPlayer
import MapKit
import GoogleCast

class MapViewController: TravelearViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var castButton: GCKUICastButton!
    var trackAnnotationId = "trackAnnotationId"
    var cellId = "listCell"
    var selectedTrack: Track?
    var mapView: MKMapView!
    var tracks = [Track]()
    var annotations = [MKAnnotation]()
    var locationManager = CLLocationManager()
    
    var mapCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.decelerationRate = UIScrollView.DecelerationRate.fast
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        
        mapView = MKMapView()
        mapView.delegate = self
        mapView.mapType = MKMapType.satellite
        view.addSubview(mapView!)
        mapView.fillSuperview()
        registerAnnotations()
        
        self.view.addSubview(mapCollectionView)
        mapCollectionView.anchor(nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 90, rightConstant: 0, widthConstant: 0, heightConstant: CGFloat(AppConstants.cellHeight))
        mapCollectionView.dataSource = self
        mapCollectionView.delegate = self
        mapCollectionView.register(MapCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        mapCollectionView.isAccessibilityElement = false
        mapCollectionView.shouldGroupAccessibilityChildren = true
        mapCollectionView.isPagingEnabled = false
        
        loadData()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.black
        let castBarButtonItem = UIBarButtonItem(customView: castButton)
        let profileButtonItem = UIBarButtonItem.init(customView: profileButton)
        self.navigationItem.rightBarButtonItems = [profileButtonItem, castBarButtonItem]
        
        self.titleLabel.font = UIFont.TravTitle()
        self.titleLabel.text = "Explore"
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.handleReachabilityNotification(_:)),
                                               name: .ReachabilityNotification,
                                               object: nil)
    }
    
    private func registerAnnotations(){
        mapView.register(MapAnnotationPinView.self,forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(MapClusterAnnotationView.self,forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    func loadData(){
        API.download(){ (list) -> () in
            self.tracks = list
            DispatchQueue.main.async {
                for track in self.tracks {
                    let trackAnnotation = TrackModelAnnotation(track: track)
                    self.annotations.append(trackAnnotation) // so we can get the index path
                    self.mapView.addAnnotation(trackAnnotation)
                }
                self.mapCollectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = mapCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MapCollectionViewCell
        
        cell.backgroundColor = UIColor.clear
        
        let track = tracks[indexPath.row]
        
        cell.track = track
        
        // content update
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = track.recorded
        
        // accessibility
        let accessDate = dateFormatter.string(from: date!)
        
        if AccessibilityService.isVoiceOver() {
            cell.isAccessibilityElement = false
            cell.stackView.accessibilityLabel = "\(track.name!)"
            cell.stackView.accessibilityValue = "Recorded on \(accessDate) in \(track.location!)"
            cell.stackView.isAccessibilityElement = true
        } else {
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = "\(track.name!)"
            cell.accessibilityValue = "Recorded on \(accessDate) in \(track.location!)"
            cell.stackView.isAccessibilityElement = false
        }
        
        // will use long press here
        cell.locationLabel.isAccessibilityElement = false
        cell.trackNameLabel.isAccessibilityElement = false
        
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(pressFavoriteButton(button:)), for: .touchUpInside)
        
        // styles
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        guard let id = track.id else { return }
        playNow(id: String(id))
        mapView.selectAnnotation(annotations[indexPath.row], animated: true)
        moveCameraTo(lat:track.latitude!, long:track.longitude!)
        AnalyticsService.logTrackPlayEvent(title: track.name!, screen: "Map Screen", id: track.id!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGSize(width: mapCollectionView.bounds.width - 44, height: CGFloat(AppConstants.cellHeight))
        } else {
            let itemWidth = ((mapCollectionView.bounds.size.width - 44) / CGFloat(2.5)).rounded(.down)
            return CGSize(width: itemWidth, height: CGFloat(AppConstants.cellHeight))
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
    
    func scrollToTrackIndex(_ trackIndex: Int) {
        let indexPath = IndexPath(item: trackIndex, section: 0)
        mapCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition(), animated: true)
    }
    
    func moveCameraTo(lat:Double, long:Double){
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        let mapCamera = MKMapCamera(lookingAtCenter: location, fromEyeCoordinate: location, eyeAltitude: 400)
        mapView.setCamera(mapCamera, animated: true)
    }
    
    func requestPlayTrack(track: Track) {
        playNow(id: track.id!)
    }
    
    @objc func playNow(id:String){
        for track in tracks {
            if id == track.id {
                let timestamp = Date()
                PlayerService.sharedInstance.load(creatorName:track.creatorName!, creatorImage:track.creatorImage!, isPublic:track.isPublic!,author:track.author!, duration:track.duration!, file:track.file!, image:track.image!, latitude:track.latitude!, longitude: track.longitude!, location:track.location!, id:track.id!, name:track.name!, recorded:track.recorded!, tags:track.tags!, timestamp:timestamp, status:true,isMonetized: track.isMonetized!, isWorld:track.isWorld!, isSleep:track.isSleep!)
            }
        }
    }
    
    @objc func handleReachabilityNotification(_ notification: Notification){
        let internet = notification.object as! Bool
        if internet {
            mapView.isHidden = false
            mapCollectionView.isHidden = false
        } else {
            mapView.isHidden = true
            mapCollectionView.isHidden = true
        }
    }
    
    @objc func pressFavoriteButton(button: UIButton){
            let track = tracks[button.tag] as! Track
            if track.isMonetized != true {
                addRemoveFavorite(track: track, button: button)
            } else {
                if UserDefaults.standard.isPurchased() == true {
                    addRemoveFavorite(track: track, button: button)
                } else {
                    Alerts.showErrorBanner("Upgrade to add favorites!")
                    showShop()
                }
            }
    }
    
    func addRemoveFavorite(track:Track, button:UIButton){
        if API.checkIfEventExists(id: track.id!) != true {
            // the event doesnt exist in favorites, add it
            button.setImage(UIImage(named: "Favorite-Selected"), for: .normal)
            API.saveFavorite(track: track)
            Alerts.showSuccessBanner("Added to Favorites")
            AnalyticsService.postToListEvent(title: track.name!, id: track.id!, list: "favorites")
            // reload
            self.reload(button.tag)
        } else {
            // the event exists in favorites, remove it
            button.setImage(UIImage(named: "Favorite"), for: .normal)
            // remove
            API.removeFavorite(id: track.id!)
            // reload
            self.reload(button.tag)
        }
    }
    
    @objc func showShop() {
         let defaults = UserDefaults.standard
         if Internet.sharedInstance.isConnectedToNetwork() == true {
             API.getUser { (User) in
                 if User.subscription_active == "active" {
                     defaults.setValue(true, forKey: "isPurchased")
                     if defaults.isLoggedIn() != true {
                         self.goToAuth()
                     }
                 } else {
                     self.goToShop()
                 }
             }
         }else {
             Alerts.showNoInternet()
         }
     }
    
    func goToShop(){
        let controller = PurchasesViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }

    func goToAuth(){
        let controller = LoginViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }
    
    func reload(_ row: Int) {
        mapCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
    }

    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? TrackModelAnnotation else { return nil }
        view.accessibilityLabel = annotation.title
        return MapAnnotationPinView(annotation: annotation, reuseIdentifier: trackAnnotationId)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        
        let selectedAnnotation = view.annotation!
        let location = selectedAnnotation.coordinate
        
        let mapCamera = MKMapCamera(lookingAtCenter: location, fromEyeCoordinate: location, eyeAltitude:5000000)
        mapView.setCamera(mapCamera, animated: true)
        
        if let i = annotations.firstIndex(where: { $0.hash == selectedAnnotation.hash }) {
            scrollToTrackIndex(i)
        }
    }
    
}


