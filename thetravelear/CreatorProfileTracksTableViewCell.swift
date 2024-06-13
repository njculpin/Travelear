//
//  CreatorProfileTracksTableViewCell.swift
//  Travelear
//
//  Created by Nicholas Culpin on 11/11/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class CreatorProfileTracksTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var tracks = [Track]()
    var cellId = "listCell"
    
    lazy var listCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.decelerationRate = UIScrollView.DecelerationRate.fast
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.backgroundColor = .white
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(listCollectionView)
        listCollectionView.fillSuperview()
        listCollectionView.reloadData()
        listCollectionView.allowsMultipleSelection = false
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.register(CreatorProfileTrackCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let Cell = listCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CreatorProfileTrackCollectionViewCell
        let track = tracks[indexPath.row]
        Cell.track = track
        Cell.accessibilityLabel = "\(String(describing: track.name)) Button"
        return Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        let timestamp = Date()
        PlayerService.sharedInstance.load(creatorName:track.creatorName!, creatorImage:track.creatorImage!, isPublic:track.isPublic!,author:track.author!, duration:track.duration!, file:track.file!, image:track.image!, latitude:track.latitude!, longitude: track.longitude!, location:track.location!, id:track.id!, name:track.name!, recorded:track.recorded!, tags:track.tags!, timestamp:timestamp, status:true,isMonetized: track.isMonetized!, isWorld:track.isWorld!, isSleep:track.isSleep!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"dismiss"), object: nil)
        AnalyticsService.logTrackPlayEvent(title: track.name!, screen: "Creator Profile Screen - \(track.author!)", id: track.id!)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            let itemWidth = ((listCollectionView.bounds.size.width - 44) / CGFloat(3.0)).rounded(.down)
            return CGSize(width: itemWidth, height: itemWidth)
        } else {
            let itemWidth = ((listCollectionView.bounds.size.width - 44) / CGFloat(9.0)).rounded(.down)
            return CGSize(width: itemWidth, height: itemWidth)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

}
