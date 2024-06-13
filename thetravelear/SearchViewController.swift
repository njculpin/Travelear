//
//  SearchViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 9/16/17.
//  Copyright © 2017 thetravelear. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MediaPlayer
import GoogleCast

class SearchViewController: TravelearViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private var castButton: GCKUICastButton!
    lazy var searchBar: UISearchBar = UISearchBar()
    var cellId = "searchCell"

    lazy var searchTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(BasicTableViewCell.self, forCellReuseIdentifier: cellId)
        return tv
    }()
    
    var tracks = [Track]()
    var filteredResults = [Track]()
    var shouldFilterResults = false
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.black
        let castBarButtonItem = UIBarButtonItem(customView: castButton)
        let profileButtonItem = UIBarButtonItem.init(customView: profileButton)
        self.navigationItem.rightBarButtonItems = [profileButtonItem, castBarButtonItem]
        
        self.titleLabel.text = "Search"
        self.titleLabel.font = UIFont.TravTitle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.handleReachabilityNotification(_:)),
                                               name: .ReachabilityNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSearchBar()
        loadTableView()
        loadData()
    }
    
    func loadSearchBar(){
        view.addSubview(searchBar)
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.backgroundColor = UIColor.white
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.delegate = self
        searchBar.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
    }
    
    func loadTableView(){
        view.addSubview(searchTableView)
        searchTableView.anchor(self.searchBar.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        searchTableView.allowsMultipleSelection = false
    }

    
    func loadData(){
        API.download(){ (list) -> () in
            self.tracks = list
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults.removeAll(keepingCapacity: false)
        filteredResults = tracks.filter({ (Track) -> Bool in
            if searchText.isEmpty {
                shouldFilterResults = false
                return true
            }
            shouldFilterResults = true
            return Track.tags!.lowercased().contains(searchText.lowercased())
        })
        
        self.searchTableView.reloadData()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.tagTerm(_:)), object: searchBar)
        perform(#selector(self.tagTerm(_:)), with: searchBar, afterDelay: 0.75)
    }
    
    @objc func tagTerm(_ searchBar: UISearchBar){
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }

        AnalyticsService.logSearchEvent(term:query)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trackCell = searchTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BasicTableViewCell
        
        if shouldFilterResults{
            let track = filteredResults[indexPath.row]
            trackCell.selectionStyle = .none
            trackCell.track = track
            trackCell.accessibilityLabel = "\(track.name!)"
            if LocalStorageManager.isLocal(track.file!) {
                trackCell.progress = 1.0
            } else {
                trackCell.progress = 0.0
            }
            return trackCell
        } else {
            let track = tracks[indexPath.row]
            trackCell.selectionStyle = .none
            trackCell.track = track
            trackCell.accessibilityLabel = "\(track.name!)"
            if LocalStorageManager.isLocal(track.file!) {
                trackCell.progress = 1.0
            } else {
                trackCell.progress = 0.0
            }
            return trackCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldFilterResults {
            return filteredResults.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filteredResults.isEmpty {
            return
        } else {
            let track = filteredResults[indexPath.row]
            let timestamp = Date()
            PlayerService.sharedInstance.load(creatorName:track.creatorName!, creatorImage:track.creatorImage!, isPublic:track.isPublic!,author:track.author!, duration:track.duration!, file:track.file!, image:track.image!, latitude:track.latitude!, longitude: track.longitude!, location:track.location!, id:track.id!, name:track.name!, recorded:track.recorded!, tags:track.tags!, timestamp:timestamp, status:true, isMonetized: track.isMonetized!, isWorld:track.isWorld!, isSleep:track.isSleep!)
            searchBar.text = nil
            shouldFilterResults = false
            self.view.endEditing(true)
            AnalyticsService.logTrackPlayEvent(title: track.name!, screen: "Search Screen", id: track.id!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.searchTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 200, right: 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    @objc func presentMorePopover(button: UIButton){
        // todo: fix this trash.
        if filteredResults.isEmpty {
            let data = tracks[button.tag]
            let track = [
                "isPublic": data.isPublic!,
                "author": data.author!,
                "duration": data.duration!,
                "file": data.file!,
                "image": data.image!,
                "longitude": data.longitude!,
                "latitude": data.latitude!,
                "location": data.location!,
                "id": data.id!,
                "name": data.name!,
                "recorded": data.recorded!,
                "tags": data.tags!,
                "timestamp": data.timestamp!
                ] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"showShare"), object: nil, userInfo: track)
        } else {
            let data = filteredResults[button.tag]
            let track = [
                "isPublic": data.isPublic!,
                "author": data.author!,
                "duration": data.duration!,
                "file": data.file!,
                "image": data.image!,
                "longitude": data.longitude!,
                "latitude": data.latitude!,
                "location": data.location!,
                "id": data.id!,
                "name": data.name!,
                "recorded": data.recorded!,
                "tags": data.tags!,
                "timestamp": data.timestamp!
                ] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"showShare"), object: nil, userInfo: track)
        }
    }
    
    @objc func handleReachabilityNotification(_ notification: Notification){
        let internet = notification.object as! Bool
        if internet {
            searchTableView.isHidden = false
        } else {
            searchTableView.isHidden = true
        }
    }

}
