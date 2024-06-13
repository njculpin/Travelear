//
//  ListViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 6/14/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleCast

class ListViewController: TravelearViewController, UITableViewDelegate, UITableViewDataSource {
    
    var upgradeBanner = UpgradeBanner(title: "Upgrade Now for Premium Features")

    var cellId = "listCell"
    var tracks = [AnyObject]()
    let upgradeBannerHeight = CGFloat(24)
    var ubShowConstraint: NSLayoutConstraint?
    var ubHideConstraint: NSLayoutConstraint?
    private var castButton: GCKUICastButton!
    private let refreshControl = UIRefreshControl()
    
    lazy var listTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(ListTableViewCell.self, forCellReuseIdentifier: cellId)
        tv.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.TravRed()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return tv
    }()
    
    override func viewDidLoad() {
                
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.handleReachabilityNotification(_:)),
                                               name: .ReachabilityNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.handlePurhaseNotification(_:)),
                                               name: .PurchaseNotification,
                                               object: nil)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.black
        let castBarButtonItem = UIBarButtonItem(customView: castButton)
        let profileButtonItem = UIBarButtonItem.init(customView: profileButton)
        self.navigationItem.rightBarButtonItems = [profileButtonItem, castBarButtonItem]
        
        self.titleLabel.text = "Travelear"
        self.titleLabel.font = UIFont.TravTitle()
        
        self.view.addSubview(upgradeBanner)
        self.view.addSubview(listTableView)
        
        ubShowConstraint = self.upgradeBanner.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        ubHideConstraint = self.upgradeBanner.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
                
        if UserDefaults.standard.isPurchased() == true {
            self.hideUpgradeBanner()
        }
        
        self.upgradeBanner.anchor(nil, left: self.view.leftAnchor, bottom: self.listTableView.topAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant:0, widthConstant: 0, heightConstant: upgradeBannerHeight)
        self.listTableView.anchor(upgradeBanner.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 66, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        self.view.backgroundColor = UIColor.white
        
        listTableView.backgroundColor = .white
        listTableView.isAccessibilityElement = false

        refreshControl.tintColor = UIColor.TravRed()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        upgradeBanner.button.addTarget(self, action: #selector(showShop), for: .touchUpInside)
        
        self.loadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.listTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    @objc func loadData(){
        API.download{ (list) -> () in
            self.tracks = list
            print()
            if UserDefaults.standard.isPurchased() != true {
                self.showUpgradeBanner()
            } else {
                self.hideUpgradeBanner()
            }
            DispatchQueue.main.async {
                self.listTableView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = tracks[indexPath.row] as! Track
        let cell = listTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListTableViewCell
        cell.track = track
        cell.selectionStyle = .none
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(pressFavoriteButton(button:)), for: .touchUpInside)
        
        if AccessibilityService.isVoiceOver() {
            cell.isAccessibilityElement = false
            cell.trackNameLabel.isAccessibilityElement = true
            cell.favoriteButton.isAccessibilityElement = true
            cell.trackNameLabel.accessibilityLabel = "\(track.name!)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let track = tracks[indexPath.row] as? Track {
            let timestamp = Date()
            PlayerService.sharedInstance.load(creatorName: track.creatorName!, creatorImage: track.creatorImage!, isPublic:track.isPublic!,author:track.author!, duration:track.duration!, file:track.file!, image:track.image!, latitude:track.latitude!, longitude: track.longitude!, location:track.location!, id:track.id!, name:track.name!, recorded:track.recorded!, tags:track.tags!, timestamp:timestamp, status:true, isMonetized: track.isMonetized!, isWorld:track.isWorld!, isSleep:track.isSleep!)
            AnalyticsService.logTrackPlayEvent(title: track.name!, screen: "Browse Screen", id: track.id!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(AppConstants.cellHeight)
    }
    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if UserDefaults.standard.isPurchased() != true {
            let contentOffsetY = scrollView.contentOffset.y
            if contentOffsetY >= upgradeBannerHeight {
                self.hideUpgradeBanner()
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion:nil)
            } else {
                self.showUpgradeBanner()
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion:nil)
            }
        }
    }
    
    func showUpgradeBanner(){
        ubShowConstraint?.isActive = true
        ubHideConstraint?.isActive = false
    }
    
    func hideUpgradeBanner(){
        ubShowConstraint?.isActive = false
        ubHideConstraint?.isActive = true
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
    
    @objc func handleReachabilityNotification(_ notification: Notification){
        let internet = notification.object as! Bool
        if internet {
            listTableView.isHidden = false
        } else {
            listTableView.isHidden = true
        }
    }
    
    @objc func handlePurhaseNotification(_ notification: Notification){
        let purchased = notification.object as! Bool
        if purchased == true {
            self.hideUpgradeBanner()
            loadData()
        } else {
            self.showUpgradeBanner()
            loadData()
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
      listTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    
}


