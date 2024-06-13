//
//  QueueViewController.swift
//  thetravelear
//
//  Created by Nicholas Culpin on 8/7/17.
//  Copyright © 2017 thetravelear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import MediaPlayer
import CoreData
import GoogleCast

class QueueViewController: TravelearViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tracks: [NSManagedObject] = []
    
    private let refreshControl = UIRefreshControl()
    private var castButton: GCKUICastButton!
    
    // data
    lazy var QueueTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(BasicTableViewCell.self, forCellReuseIdentifier: "QueueCell")
        tv.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.TravRed()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return tv
    }()
    
    
    override func viewDidLoad() {
        setupViews()
        loadData()
    }
    
    @objc func loadData(){
        // CORE DATA
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "QueueTrack")
        
        do {
          tracks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        DispatchQueue.main.async {
            self.QueueTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.QueueTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
    }
    
    func setupViews() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(QueueTableView)
        QueueTableView.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 55, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        QueueTableView.reloadData()
        QueueTableView.allowsMultipleSelection = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.black
        let castBarButtonItem = UIBarButtonItem(customView: castButton)
        let profileButtonItem = UIBarButtonItem.init(customView: profileButton)
        self.navigationItem.rightBarButtonItems = [profileButtonItem, castBarButtonItem]
        
        self.titleLabel.text = "Your Trip"
        self.titleLabel.font = UIFont.TravTitle()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = QueueTableView.dequeueReusableCell(withIdentifier: "QueueCell", for: indexPath) as! BasicTableViewCell

        let trackIndex = tracks[indexPath.row]
        
        let track = Track(
            creatorName: trackIndex.value(forKeyPath: "creatorName") as! String,
            creatorImage: trackIndex.value(forKeyPath: "creatorImage") as! String,
            isPublic: trackIndex.value(forKeyPath: "isPublic") as! Bool,
            author: trackIndex.value(forKeyPath: "author") as! String,
            duration: trackIndex.value(forKeyPath: "duration") as! String,
            file: trackIndex.value(forKeyPath: "file") as! String,
            image: trackIndex.value(forKeyPath: "image") as! String,
            latitude: trackIndex.value(forKeyPath: "latitude") as! Double,
            longitude: trackIndex.value(forKeyPath: "longitude") as! Double,
            location: trackIndex.value(forKeyPath: "location") as! String,
            id: trackIndex.value(forKeyPath: "id") as! String,
            name: trackIndex.value(forKeyPath: "name") as! String,
            recorded: trackIndex.value(forKeyPath: "recorded") as! Date,
            tags: trackIndex.value(forKeyPath: "tags") as! String,
            timestamp: trackIndex.value(forKeyPath: "timestamp") as! Date,
            isMonetized: trackIndex.value(forKeyPath: "isMonetized") as! Bool,
            isSleep: trackIndex.value(forKeyPath: "isSleep") as! Bool,
            isWorld: trackIndex.value(forKeyPath: "isWorld") as! Bool)
        
        Cell.track = track
        
        Cell.selectionStyle = .none
        Cell.moreButton.tag = indexPath.row
        Cell.moreButton.addTarget(self, action: #selector(presentMorePopover(button:)), for: .touchUpInside)
        if LocalStorageManager.isLocal(track.file!) {
            Cell.progress = 1.0
        } else {
            Cell.progress = 0.0
        }
        return Cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let trackIndex = tracks[indexPath.row]
        
        let track = Track(
            creatorName: trackIndex.value(forKeyPath: "creatorName") as! String,
            creatorImage: trackIndex.value(forKeyPath: "creatorImage") as! String,
            isPublic: trackIndex.value(forKeyPath: "isPublic") as! Bool,
            author: trackIndex.value(forKeyPath: "author") as! String,
            duration: trackIndex.value(forKeyPath: "duration") as! String,
            file: trackIndex.value(forKeyPath: "file") as! String,
            image: trackIndex.value(forKeyPath: "image") as! String,
            latitude: trackIndex.value(forKeyPath: "latitude") as! Double,
            longitude: trackIndex.value(forKeyPath: "longitude") as! Double,
            location: trackIndex.value(forKeyPath: "location") as! String,
            id: trackIndex.value(forKeyPath: "id") as! String,
            name: trackIndex.value(forKeyPath: "name") as! String,
            recorded: trackIndex.value(forKeyPath: "recorded") as! Date,
            tags: trackIndex.value(forKeyPath: "tags") as! String,
            timestamp: trackIndex.value(forKeyPath: "timestamp") as! Date,
            isMonetized: trackIndex.value(forKeyPath: "isMonetized") as! Bool,
            isSleep: trackIndex.value(forKeyPath: "isSleep") as! Bool,
            isWorld: trackIndex.value(forKeyPath: "isWorld") as! Bool)
        
        PlayerService.sharedInstance.load(creatorName: track.creatorName!, creatorImage: track.creatorImage!, isPublic:track.isPublic!,author:track.author!, duration:track.duration!, file:track.file!, image:track.image!, latitude:track.latitude!, longitude: track.longitude!, location:track.location!, id:track.id!, name:track.name!, recorded:track.recorded!, tags:track.tags!, timestamp:Date(), status:true,isMonetized: track.isMonetized!, isWorld:track.isWorld!, isSleep:track.isSleep!)
        PlayerService.sharedInstance.currentIndex = indexPath.row
        AnalyticsService.logTrackPlayEvent(title: track.name!, screen: "Queue Screen", id: track.id!)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        // Remove from core data
        let commit = tracks[indexPath.row]
        let index = indexPath.item
        self.tracks.remove(at: index)
        self.QueueTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        managedContext.delete(commit)

        do {
            try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        // Remove from table
        self.QueueTableView.reloadData()
    }
    
    @objc func presentMorePopover(button: UIButton){

        let trackIndex = tracks[button.tag]
        
        let track = Track(
            creatorName: trackIndex.value(forKeyPath: "creatorName") as! String,
            creatorImage: trackIndex.value(forKeyPath: "creatorImage") as! String,
            isPublic: trackIndex.value(forKeyPath: "isPublic") as! Bool,
            author: trackIndex.value(forKeyPath: "author") as! String,
            duration: trackIndex.value(forKeyPath: "duration") as! String,
            file: trackIndex.value(forKeyPath: "file") as! String,
            image: trackIndex.value(forKeyPath: "image") as! String,
            latitude: trackIndex.value(forKeyPath: "latitude") as! Double,
            longitude: trackIndex.value(forKeyPath: "longitude") as! Double,
            location: trackIndex.value(forKeyPath: "location") as! String,
            id: trackIndex.value(forKeyPath: "id") as! String,
            name: trackIndex.value(forKeyPath: "name") as! String,
            recorded: trackIndex.value(forKeyPath: "recorded") as! Date,
            tags: trackIndex.value(forKeyPath: "tags") as! String,
            timestamp: trackIndex.value(forKeyPath: "timestamp") as! Date,
            isMonetized: trackIndex.value(forKeyPath: "isMonetized") as! Bool,
            isSleep: trackIndex.value(forKeyPath: "isSleep") as! Bool,
            isWorld: trackIndex.value(forKeyPath: "isWorld") as! Bool)
        
        let trackData = [
            "isPublic": track.isPublic!,
            "author": track.author!,
            "duration": track.duration!,
            "file": track.file!,
            "image": track.image!,
            "longitude": track.longitude!,
            "latitude": track.latitude!,
            "location": track.location!,
            "id": track.id!,
            "name": track.name!,
            "recorded": track.recorded!,
            "tags": track.tags!,
            "timestamp": track.timestamp!
            ] as [String : Any]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"showShare"), object: nil, userInfo: trackData)
    }
    
}
