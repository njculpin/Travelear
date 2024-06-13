//
//  PlayerService.swift
//  Travelear
//
//  Created by Nicholas Culpin on 12/2/17.
//  Copyright © 2017 thetravelear. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MediaPlayer
import GoogleCast
import CoreData

public class PlayerService {
    
    static let sharedInstance = PlayerService()
    let db = Firestore.firestore()
    
    var crossFadeDuration: Double = 1
    let preferredTimeScale: Int32 = 1
    var timeObserverToken: Any?
    
    var player: AVPlayer!
    var playerItem:AVPlayerItem?
    let infoCenter = MPNowPlayingInfoCenter.default()
    
    var url = String()
    
    // record values for play count
    var name = String()
    var id = String()
    var author = String()
    var location = String()
    
    var tracks = [AnyObject]()
    var currentIndex = 0

    
    private init() {
        setUp()
    }
    
    func setUp(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
        self.setupAVAudioSession()
    }
    
    
    func load(creatorName:String, creatorImage:String, isPublic: Bool, author:String, duration:Double, file:String, image:String, latitude:Double, longitude:Double, location: String, id:String, name:String, recorded:Date, tags:String, timestamp:Date, status:Bool, isMonetized:Bool, isWorld:Bool, isSleep:Bool ){
        
        DispatchQueue.main.async {
            
            let trackData = [
                "name": name,
                "file": file,
                "image": image,
                "duration": duration,
                "id": id,
                "author": author,
                "creatorName": creatorName,
                "creatorImage": creatorImage,
                "isMonetized": isMonetized,
                "isSleep": isSleep,
                "isWorld": isWorld,
                "isPublic": isPublic,
                "latitude": latitude,
                "longitude": longitude,
                "location": location,
                "recorded": recorded,
                "tags": tags,
                "timestamp": timestamp
            ] as [String : Any]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"updateNowPlaying"), object: nil, userInfo: trackData)
            
            // warn headphones use
            if CheckHeadphones.isConnected() != true {
                AnalyticsService.logHeadphoneUse(headphones: false, trackId: id)
                Analytics.setUserProperty("no", forName: "using_headphones")
            } else {
                AnalyticsService.logHeadphoneUse(headphones: true, trackId: id)
                Analytics.setUserProperty("yes", forName: "using_headphones")
            }
            
            // record these for play count
            self.author = author
            self.id = id
            self.name = name
            self.location = location
            if isMonetized == true {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"checkMonetized"), object: nil)
            }
            
            if LocalStorageManager.isLocal(file) {
                let itemStream = NSURL(string: file)! as URL
                let local = LocalStorageManager.localFilePathForUrl(itemStream)!
                self.playerItem = AVPlayerItem(url:local)
            } else {
                let itemStream = NSURL(string: file)! as URL
                self.playerItem = AVPlayerItem(url:itemStream)
            }
            
            // load player
            self.player = AVPlayer(playerItem:self.playerItem)
            self.player.automaticallyWaitsToMinimizeStalling = false
            
            // decide if the player should start immediately or just load to pause
            if status {
                self.player.rate = 1.0
                self.player.play()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"setUI"), object: nil)
            } else {
                self.player.rate = 0.0
                self.player.pause()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"setUI"), object: nil)
            }
            

            self.monitorDidFinishPlaying() // monitor end of track
            
        }
    }
    
    
    func checkIfPlaying()->Bool{
        if player.rate != 0.0 {
            return false
        } else {
            return true
        }
    }
    
    @objc func play(){
        player.rate = 1.0
        player.play()
        updateInfoCenter()
    }
    
    @objc func pause(){
        player.rate = 0.0
        updateInfoCenter()
    }
    
    func timeSliderPressed(playerDetailTargetTime:CMTime){
        player.seek(to: playerDetailTargetTime)
        
        if player.currentItem != nil {
            self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(playerDetailTargetTime)
            self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"setUI"), object: nil)
        }

        if player.rate == 0{
            player.play()
        }
    }
    
    func monitorDidFinishPlaying(){
        NotificationCenter.default.addObserver(self, selector: #selector(endOfTrack), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    @objc func endOfTrack(){
        AnalyticsService.logTrackFinishEvent(title: self.name, id: self.id)
        player.seek(to: CMTime.zero)
        player.play()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"setUI"), object: nil)
    }
    
    func getCurrentTime(completionHandler: @escaping (_ time: Float64) -> ()){
        var time = Float64()
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player.currentItem?.status == .readyToPlay {
                time = CMTimeGetSeconds(self.player.currentTime())
                completionHandler(time)
            }
        }
    }
    
    func secondsToMinutesSeconds (_ seconds : Int) -> String{
        let min : Int = (seconds % 3600) / 60
        let sec : Int = (seconds % 3600) % 60
        return String(format:"%02i:%02i", min, sec)
    }
    
    func playCount(){
        let name = self.name
        let id = self.id
        let author = self.author
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-M-d"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let documentID = id+"_"+dateString
        if Auth.auth().currentUser != nil {
            db.collection("play-counts").document(documentID).getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let dataDescription = document.data() else { return }
                    let currentCount = dataDescription["plays"] as! Int
                    let newCount = currentCount + 1
                    self.db.collection("play-counts").document(documentID).updateData([
                        "plays" : newCount
                        ])
                } else {
                    self.db.collection("play-counts").document(documentID).setData([
                        "author": author,
                        "date": dateString,
                        "id": id,
                        "name": name,
                        "plays" : 1
                    ])
                }
            }
        }
    }
    
    private func setupAVAudioSession(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupInfoCenter()
        } catch {
            debugPrint("Error: \(error)")
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
    // MARK: Info Center / Lock Screen Playback
    func setupInfoCenter(){
        // set track to user default for now playing
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if self?.player.currentItem != nil {
                self?.play()
                self?.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((self?.player.currentTime())!)
                self?.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"setUI"), object: nil)
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if self?.player.currentItem != nil {
                self?.pause()
                self?.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((self?.player.currentTime())!)
                self?.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"setUI"), object: nil)
            return .success
        }
        

    }
    
   func updateInfoCenter(){
        self.infoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: self.name,
            MPMediaItemPropertyArtist: self.location,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            ]
    }    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
