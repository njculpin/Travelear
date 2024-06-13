//
//  PlaylistViewController.swift
//  thetravelear
//
//  Created by Nicholas Culpin on 1/11/17.
//  Copyright © 2017 thetravelear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MediaPlayer
import CoreData
import GoogleCast

class FavoritesViewController: TravelearViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var castButton: GCKUICastButton!
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let downloadService = DownloadService()
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    private let refreshControl = UIRefreshControl()
    
    lazy var FavoritesTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(BasicTableViewCell.self, forCellReuseIdentifier: "FavoritesCell")
        tv.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.TravRed()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return tv
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = UIStackView.Distribution.equalSpacing
        view.alignment = .center
        view.backgroundColor = .white
        return view
    }()
    
    lazy var downloadLabel = TravelearLabel()
    
    lazy var downloadSelector: UISwitch = {
        let sb = UISwitch()
        sb.isOn = false
        sb.setOn(false, animated: false)
        sb.addTarget(self, action: #selector(toggleDownload(_:)), for: .valueChanged)
        sb.onTintColor = UIColor.TravRed()
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    let defaults = UserDefaults.standard
    
    var tracks: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadService.downloadsSession = downloadsSession
        
        view.backgroundColor = UIColor.white
        FavoritesTableView.allowsMultipleSelection = true

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.black
        let castBarButtonItem = UIBarButtonItem(customView: castButton)
        let profileButtonItem = UIBarButtonItem.init(customView: profileButton)
        self.navigationItem.rightBarButtonItems = [profileButtonItem, castBarButtonItem]
        
        self.titleLabel.text = "Favorites"
        self.titleLabel.font = UIFont.TravTitle()
        
        self.view.addSubview(self.stackView)
        self.view.addSubview(FavoritesTableView)
        stackView.addArrangedSubview(downloadLabel)
        stackView.addArrangedSubview(downloadSelector)
        
        downloadLabel.text = "Download"
        
        stackView.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: FavoritesTableView.topAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 44)
        
        FavoritesTableView.anchor(nil, left: self.view.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        loadData()        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.FavoritesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if defaults.isDownloaded() == true {
            downloadAll()
        }
    }
    
    @objc func loadData(){
        // CORE DATA
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteTrack")
        
        do {
          tracks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        DispatchQueue.main.async {
            self.FavoritesTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
        
        if defaults.isDownloaded() == true {
            downloadSelector.setOn(true, animated: false)
        } else {
            downloadSelector.setOn(false, animated: false)
        }
    }
    


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = FavoritesTableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as! BasicTableViewCell
        
        Cell.delegate = self
    
        let trackIndex = tracks[indexPath.row]
        
        let track = Track(
            creatorName: trackIndex.value(forKeyPath: "creatorName") as! String,
            creatorImage: trackIndex.value(forKeyPath: "creatorImage") as! String,
            isPublic: trackIndex.value(forKeyPath: "isPublic") as! Bool,
            author: trackIndex.value(forKeyPath: "author") as! String,
            duration: trackIndex.value(forKeyPath: "duration") as! Double,
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
        Cell.accessibilityLabel = "\(String(describing: track.name))"
        
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
            duration: trackIndex.value(forKeyPath: "duration") as! Double,
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
        
        PlayerService.sharedInstance.load(creatorName: track.creatorName!, creatorImage: track.creatorImage!, isPublic:track.isPublic!,author:track.author!, duration:track.duration!, file:track.file!, image:track.image!, latitude:track.latitude!, longitude: track.longitude!, location:track.location!, id:track.id!, name:track.name!, recorded:track.recorded!, tags:track.tags!, timestamp:Date(), status:true, isMonetized: track.isMonetized!, isWorld:track.isWorld!, isSleep:track.isSleep!)

        AnalyticsService.logTrackPlayEvent(title: track.name!, screen: "Favorites Screen", id: track.id!)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    // MARK: Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let trackIndex = tracks[indexPath.row]
        
        let track = Track(
            creatorName: trackIndex.value(forKeyPath: "creatorName") as! String,
            creatorImage: trackIndex.value(forKeyPath: "creatorImage") as! String,
            isPublic: trackIndex.value(forKeyPath: "isPublic") as! Bool,
            author: trackIndex.value(forKeyPath: "author") as! String,
            duration: trackIndex.value(forKeyPath: "duration") as! Double,
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
        
        // Remove from firebase
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["favorites": FieldValue.arrayRemove([track.id!])])
        
        // Remove from core data
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
        self.FavoritesTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        managedContext.delete(commit)

        do {
            try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        // Remove file if downloaded
        DownloadService.delete(track)

        self.FavoritesTableView.reloadData()
    }
     
     @objc func deleteAll(){
        if tracks.isEmpty == false {
            for section in 0..<FavoritesTableView.numberOfSections {
                let totalRows = FavoritesTableView.numberOfRows(inSection: section)
                for row in 0..<totalRows {
                    let downloadIndexPath = IndexPath(row: row, section: section)
                    let Cell = self.FavoritesTableView.cellForRow(at: downloadIndexPath) as! BasicTableViewCell
                    DownloadService.delete(Cell.track!)
                    Cell.progress = 0.0
                }
            }
        } else {
            Alerts.showErrorBanner("Please add tracks to favorites")
        }
     }
     
    // MARK: Download
    @objc func downloadAll(){
        if tracks.isEmpty == false {
            for section in 0..<FavoritesTableView.numberOfSections {
                let totalRows = FavoritesTableView.numberOfRows(inSection: section)
                for row in 0..<totalRows {
                    let downloadIndexPath = IndexPath(row: row, section: section)
                    let Cell = self.FavoritesTableView.cellForRow(at: downloadIndexPath) as! BasicTableViewCell
                    if LocalStorageManager.isLocal(Cell.track!.file!) {
                    } else {
                        Cell.downloadButtonPressed()
                    }
                }
            }
        } else {
            Alerts.showErrorBanner("Please add tracks to favorites")
        }
    }
    
    @objc func toggleDownload(_ sender: UISwitch!) {
        let defaults = UserDefaults.standard
        if Internet.sharedInstance.isConnectedToNetwork() == true {
            API.getUser { (User) in
                
                if User.subscription_active == "active" {
                    defaults.setValue(true, forKey: "isPurchased")
                    
                    if self.tracks.isEmpty == false {
                        if (sender.isOn == true){
                            self.downloadAll()
                            defaults.setValue(true, forKey: "isDownloaded")
                        } else{
                            self.deleteAll()
                            defaults.setValue(false, forKey: "isDownloaded")
                        }
                    } else {
                        self.downloadSelector.setOn(false, animated: true)
                        Alerts.showErrorBanner("Please add tracks to favorites")
                    }
                    
                } else {
                    self.downloadSelector.setOn(false, animated: true)
                    self.goToShop()
                }
            }
            
        }else {
            self.downloadSelector.setOn(false, animated: true)
            Alerts.showNoInternet()
        }
    }
    
    // MARK: Share
    @objc func presentMorePopover(button: UIButton){
        
        let trackIndex = tracks[button.tag]
        
        let track = Track(
            creatorName: trackIndex.value(forKeyPath: "creatorName") as! String,
            creatorImage: trackIndex.value(forKeyPath: "creatorImage") as! String,
            isPublic: trackIndex.value(forKeyPath: "isPublic") as! Bool,
            author: trackIndex.value(forKeyPath: "author") as! String,
            duration: trackIndex.value(forKeyPath: "duration") as! Double,
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
    
    func giveNotification(name:String){
        let name = ["name":name] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"notifyAdd"), object: nil, userInfo: name)
    }
    
    func reload(_ row: Int) {
      FavoritesTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}


// MARK: Cell Delegate
extension FavoritesViewController: BasicCellDelegate {
  
  func downloadButtonPressed(_ cell: BasicTableViewCell) {
    if let indexPath = self.FavoritesTableView.indexPath(for: cell) {
        let trackIndex = tracks[indexPath.row]
        let track = Track(
            creatorName: trackIndex.value(forKeyPath: "creatorName") as! String,
            creatorImage: trackIndex.value(forKeyPath: "creatorImage") as! String,
            isPublic: trackIndex.value(forKeyPath: "isPublic") as! Bool,
            author: trackIndex.value(forKeyPath: "author") as! String,
            duration: trackIndex.value(forKeyPath: "duration") as! Double,
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
        if LocalStorageManager.isLocal(track.file!) {
            return
        } else {
            self.downloadService.startDownload(track, index: indexPath.row)
            self.reload(indexPath.row)
        }
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
}

// MARK: Session Delegate
extension FavoritesViewController: URLSessionDelegate {
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        completionHandler()
      }
    }
  }
}

// MARK: Session Download Delegate
extension FavoritesViewController: URLSessionDownloadDelegate {
    
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let sourceURL = downloadTask.originalRequest?.url else { return }
    downloadService.activeDownloads[sourceURL] = nil
    let destinationURL = LocalStorageManager.localFilePathForUrl(sourceURL)
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: destinationURL!)
    do {
        try fileManager.copyItem(at: location, to: destinationURL!)
    } catch let error {
      print("Could not copy file to disk: \(error.localizedDescription)")
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64,totalBytesExpectedToWrite: Int64) {
    guard let url = downloadTask.originalRequest?.url, let download = downloadService.activeDownloads[url]  else { return }
    download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
    DispatchQueue.main.async {
      if let trackCell = self.FavoritesTableView.cellForRow(at: IndexPath(row: download.index,section: 0)) as? BasicTableViewCell {
        trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
      }
    }
  }
}
