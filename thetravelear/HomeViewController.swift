//
//  HomeViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 1/15/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AVKit
import AVFoundation
import SwiftMessages
import GoogleCast

class HomeViewController: UIViewController,  UIPopoverPresentationControllerDelegate, UITabBarControllerDelegate,
    GCKLoggerDelegate,
    GCKRequestDelegate,
    GCKRemoteMediaClientListener
{

    let tabBar = UITabBarController()
    let playerBar = PlayerBar()
    var isLooping = Bool()
    var isShuffle = Bool()
    var timer: Timer!
    
    // cast media
    private var sessionManager: GCKSessionManager!
    var mediaInformation: GCKMediaInformation? {
      didSet {
        print("setMediaInfo: \(String(describing: mediaInformation))")
      }
    }
    
    var activeViewConstraints: [NSLayoutConstraint] = [] {
        willSet {
            NSLayoutConstraint.deactivate(activeViewConstraints)
        }
        didSet {
            NSLayoutConstraint.activate(activeViewConstraints)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setCurrentTimeUI), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkMonetized), name: NSNotification.Name(rawValue: "checkMonetized"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setPlayerUI), name: NSNotification.Name(rawValue: "setUI"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlaying), name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyAdd), name: NSNotification.Name(rawValue: "notifyAdd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProfilePopOver), name: NSNotification.Name(rawValue: "showProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showShop), name: NSNotification.Name(rawValue: "showShop"), object: nil)
        
        playerBar.pausePlayButton.addTarget(self, action: #selector(pausePlay), for: UIControl.Event.touchUpInside)
        playerBar.timeSlider.addTarget(self, action: #selector(timeSliderPressed), for: UIControl.Event.touchUpInside)

        
        let listController = ListViewController()
        listController.tabBarItem = UITabBarItem.init(title: "Browse", image: UIImage(named: "list"), tag: 0)
        
//        let mapController = MapViewController()
//        mapController.tabBarItem = UITabBarItem.init(title: "Explore", image: UIImage(named: "map"), tag: 1)
        
        let searchController = SearchViewController()
        searchController.tabBarItem = UITabBarItem.init(title: "Search", image: UIImage(named: "search"), tag: 2)

        let favoritesController = FavoritesViewController()
        favoritesController.tabBarItem = UITabBarItem.init(title: "Favorites", image: UIImage(named: "favorite"), tag: 3)
        
        let vc = [listController, searchController, favoritesController] // hide map if voice over on
        tabBar.viewControllers = vc.map{ UINavigationController.init(rootViewController: $0)}
        
//        if AccessibilityService.isVoiceOver() {
//            let vc = [listController, searchController, favoritesController] // hide map if voice over on
//            tabBar.viewControllers = vc.map{ UINavigationController.init(rootViewController: $0)}
//        } else {
//            let vc = [listController, mapController, searchController, favoritesController ]
//            tabBar.viewControllers = vc.map{ UINavigationController.init(rootViewController: $0)}
//        }

        self.tabBar.delegate = self
        
        if IAPManager.shared.hasPromotedPayment {
                self.showShop()
        }
        
        setMultiTouchPausePlay()
        
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isShuffle = false
        isLooping = false
        loadTabBar()
        loadPlayerBar()
    }
    
    func loadTabBar(){
        self.view.addSubview(tabBar.view)
        tabBar.tabBar.itemPositioning = .fill
        tabBar.tabBar.isTranslucent = false
        let topBorder = CALayer()
        topBorder.frame = CGRect(x:0,y:0,width:1000,height:0.5)
        topBorder.backgroundColor = UIColor.lightGray.cgColor
        tabBar.tabBar.layer.addSublayer(topBorder)
        tabBar.tabBar.clipsToBounds = true
        tabBar.tabBar.tintColor = UIColor.TravRed()
        tabBar.tabBar.unselectedItemTintColor = UIColor.TravDarkBlue()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBar.tabBar.invalidateIntrinsicContentSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.layoutIfNeeded()
        self.tabBar.tabBar.invalidateIntrinsicContentSize()
        playerBar.layoutIfNeeded()
    }
    
    func loadPlayerBar(){
        self.view.addSubview(playerBar)
        playerBar.translatesAutoresizingMaskIntoConstraints = false
        playerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerBar.heightAnchor.constraint(equalToConstant: 94).isActive = true
        activeViewConstraints = [
            playerBar.bottomAnchor.constraint(equalTo: self.tabBar.tabBar.topAnchor, constant: 0),
        ]
        playerBar.backgroundColor = .white
        self.view.layoutIfNeeded()
    }

    // MARK: PLAYER CONTROLS
    @objc func timeSliderPressed(){
        let playerDetailseconds : Int64 = Int64(playerBar.timeSlider.value)
        let playerDetailTargetTime:CMTime = CMTimeMake(value: playerDetailseconds, timescale: 1)
        PlayerService.sharedInstance.timeSliderPressed(playerDetailTargetTime: playerDetailTargetTime)
        setPlayerUI()
    }
    
    func setMultiTouchPausePlay(){
        let doubleTapGesture = UITapGestureRecognizer(target: self , action: #selector(HomeViewController.handleDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTapGesture(_ gesture: UITapGestureRecognizer){
        pausePlay()
    }
    
    @objc func pausePlay(){
        if PlayerService.sharedInstance.checkIfPlaying() {
            PlayerService.sharedInstance.play()
            setPlayerUI()
        } else {
            PlayerService.sharedInstance.pause()
            setPlayerUI()
        }
    }
    
    //MARK: PLAYER UI UPDATES
    @objc func setPlayerUI(){
        if PlayerService.sharedInstance.checkIfPlaying() {
            setPlayButtonUI()
            setTimeSliderUI()
        } else {
            setPauseButtonUI()
            setTimeSliderUI()
        }
    }
    
    func setPlayButtonUI(){
        playerBar.pausePlayButton.setImage(UIImage(named: "playBig.png"), for: UIControl.State.normal)
        playerBar.pausePlayButton.accessibilityLabel = "Play"
    }
    
    func setPauseButtonUI(){
        playerBar.pausePlayButton.setImage(UIImage(named: "pauseBig.png"), for: UIControl.State.normal)
        playerBar.pausePlayButton.accessibilityLabel = "Pause"
    }
    
    @objc func updateNowPlaying(_ notification: NSNotification){
        let name = notification.userInfo!["name"]! as! String
        let file = notification.userInfo!["file"]! as! String
        let image = notification.userInfo!["image"]! as! String
        let duration = notification.userInfo!["duration"]! as! Double
        let id = notification.userInfo!["id"]! as! String
        let author = notification.userInfo!["author"]! as! String
        let creatorName = notification.userInfo!["creatorName"]! as! String
        let creatorImage = notification.userInfo!["creatorImage"]! as! String
        let isMonetized = notification.userInfo!["isMonetized"]! as! Bool
        let isSleep = notification.userInfo!["isSleep"]! as! Bool
        let isWorld = notification.userInfo!["isWorld"]! as! Bool
        let isPublic = notification.userInfo!["isPublic"]! as! Bool
        let latitude = notification.userInfo!["latitude"]! as! Double
        let longitude = notification.userInfo!["longitude"]! as! Double
        let location = notification.userInfo!["location"]! as! String
        let recorded = notification.userInfo!["recorded"]! as! Date
        let tags = notification.userInfo!["tags"]! as! String
        let timestamp = notification.userInfo!["timestamp"]! as! Date
        
        let track = Track(creatorName: creatorName, creatorImage: creatorImage, isPublic: isPublic, author: author, duration: duration, file: file, image: image, latitude: latitude, longitude: longitude, location: location, id: id, name: name, recorded: recorded, tags: tags, timestamp: timestamp, isMonetized: isMonetized, isSleep: isSleep, isWorld: isWorld)
        
        // playerBar.track = track
        playerBar.track = track
        setCastMeta(title: name, location: location, creatorName: creatorName, image: image, file: file)
    }
    
    func setTimeSliderUI(){
        playerBar.timeSlider.minimumValue = 0
        if PlayerService.sharedInstance.playerItem != nil {
            let duration : CMTime = PlayerService.sharedInstance.playerItem!.asset.duration
            let seconds : Float64 = CMTimeGetSeconds(duration)
            self.playerBar.timeSlider.maximumValue = Float(seconds)
            self.playerBar.timeSlider.isContinuous = false
        }
    }
    
    @objc func setCurrentTimeUI(){
        playerBar.timeSlider.minimumValue = 0
        if PlayerService.sharedInstance.player != nil {
            PlayerService.sharedInstance.getCurrentTime{
                time in
                self.playerBar.timeSlider.value = Float(time)
                let currentTime:Int = Int(time)
                let ctime = PlayerService.sharedInstance.secondsToMinutesSeconds(currentTime)
                self.playerBar.currentTimeLabel.text = ctime
                self.playerBar.currentTimeLabel.accessibilityValue = "current time is \(ctime)"
                if currentTime == 30 {
                    PlayerService.sharedInstance.playCount()
                }
            }
        }
    }
    
        @objc func checkMonetized(_ notification: NSNotification){
        let defaults = UserDefaults.standard
        if Internet.sharedInstance.isConnectedToNetwork() == true {
            API.getUser { (User) in
                if User.subscription_active == "active" {
                    defaults.setValue(true, forKey: "isPurchased")
                } else {
                    self.showShop()
                    self.pausePlay()
                }
            }
        } else {
            Alerts.showNoInternet()
        }
    }

    // MARK: Pop Overs
    @objc func notifyAdd(_ notification: NSNotification){
        let name = notification.userInfo!["name"]! as? String
        let text = "Added to \(name!)!"
        showBanner(text)
    }
    
    func showBanner(_ text: String) {
        let banner = MessageView.viewFromNib(layout: .cardView)
        banner.configureTheme(.success)
        banner.button?.isHidden = true
        banner.backgroundView.backgroundColor = UIColor.TravRed()
        banner.configureContent(title: "Great", body: text)
        SwiftMessages.show(view: banner)
    }
    
    @objc func showProfilePopOver(_ notification: NSNotification){
        let controller = ProfileViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }
    
    @objc func showShop(){
        let controller = PurchasesViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }
    // MARK: CAST
    func switchToLocalPlayback() {
      sessionManager.currentCastSession?.remoteMediaClient?.remove(self)
    }


    func switchToRemotePlayback() {
      sessionManager.currentCastSession?.remoteMediaClient?.add(self)
    }
    
    // MARK: - CAST data
    func setCastMeta(title:String, location:String, creatorName:String, image:String, file:String){
        let metadata = GCKMediaMetadata()
        metadata.setString(title, forKey: kGCKMetadataKeyTitle)
        metadata.setString("By \(creatorName), recorded in \(location)", forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: URL(string: image)!,width: 512,height: 512))
        
        let url = URL.init(string: file)
        guard let mediaURL = url else {
          print("cast : invalid mediaURL")
          return
        }

        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: mediaURL)
        mediaInfoBuilder.streamType = GCKMediaStreamType.none
        mediaInfoBuilder.contentType = "audio/mp3"
        mediaInfoBuilder.metadata = metadata
        mediaInformation = mediaInfoBuilder.build()
        
        guard let mediaInfo = mediaInformation else {
          print("cast : invalid mediaInformation")
          return
        }
        
        print("cast : mediaInfo \(mediaInfo)")

        if let request = sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInfo) {
            request.delegate = self
        }
    }
    
    // MARK: - GCKRequestDelegate

    func requestDidComplete(_ request: GCKRequest) {
      print("cast : request \(Int(request.requestID)) completed")
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
      print("cast : request \(Int(request.requestID)) failed with error \(error)")
    }
    
    // MARK: - GCKSessionManagerListener

    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
      print("cast : MediaViewController: sessionManager didStartSession \(session)")
      switchToRemotePlayback()
    }

    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
      print("cast : MediaViewController: sessionManager didResumeSession \(session)")
      switchToRemotePlayback()
    }

    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
      print("cast : session ended with error: \(String(describing: error))")
      switchToLocalPlayback()
    }

    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
      if let error = error {
        print("cast : Failed to start a session \(error.localizedDescription)")
      }
    }

    func sessionManager(_: GCKSessionManager,
                        didFailToResumeSession _: GCKSession, withError error: Error?) {
        print("cast : did fail to resume session \(error?.localizedDescription)")
      switchToLocalPlayback()
    }
    
}

