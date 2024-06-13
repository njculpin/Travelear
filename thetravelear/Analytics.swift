//
//  Analytics.swift
//  Travelear
//
//  Created by Nicholas Culpin on 5/28/19.
//  Copyright © 2019 thetravelear. All rights reserved.
//

import Foundation
import Firebase

class AnalyticsService {
    
    class func logHeadphoneUse(headphones:Bool, trackId:String){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            let isUsingVoiceOver = UserDefaults.standard.isUsingVoiceOver()
            Analytics.logEvent("TrackPlaying", parameters: [
                "app": "world-ios",
                "trackId": trackId,
                "headphones": headphones,
                "uid": uid,
                "isUsingVoiceOver": isUsingVoiceOver
                ])
        }
    }
    
    
    class func logTrackPlayEvent(title: String, screen:String, id:String){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            Analytics.logEvent("TrackPlaying", parameters: [
                "app": "world-ios",
                "id": id,
                "title": title,
                "screen": screen,
                "uid": uid,
                "isUsingVoiceOver": AccessibilityService.isVoiceOver(),
                "isUsingHeadphones" : CheckHeadphones.isConnected()
                ])
        }
    }
    
    class func logTrackFinishEvent(title:String, id:String){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            Analytics.logEvent("TrackFinished", parameters: [
                "app": "world-ios",
                "id": id,
                "title": title,
                "uid":uid,
                "isUsingVoiceOver": AccessibilityService.isVoiceOver(),
                "isUsingHeadphones" : CheckHeadphones.isConnected()
                ])
        }
    }
    
    class func postToListEvent(title:String, id:String, list:String){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            Analytics.logEvent("TrackPostedToList", parameters: [
                "app": "world-ios",
                "id": id,
                "title": title,
                "list": list,
                "uid":uid,
                "isUsingVoiceOver": AccessibilityService.isVoiceOver()
                ])
        }
    }
    
    class func logShareEvent(title: String, id:String){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            Analytics.logEvent(AnalyticsEventShare, parameters: [
                "app": "world-ios",
                "id": id,
                "title": title,
                "uid":uid,
                "isUsingVoiceOver": AccessibilityService.isVoiceOver()
                ])
        }
    }

    class func logSearchEvent(term:String){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                AnalyticsParameterSearchTerm: term,
                "app": "world-ios",
                "uid":uid
                ])
        }
    }
    
    class func logRegisterEvent(){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                "app": "world-ios",
                "uid":uid,
                "isUsingVoiceOver": AccessibilityService.isVoiceOver()
            ])
        }
    }
    
    class func logLoginEvent(){
        if AppConstants.isAppStore() {
            let user = Auth.auth().currentUser
            let uid = user!.uid
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                "app": "world-ios",
                "uid":uid,
                "isUsingVoiceOver": AccessibilityService.isVoiceOver()
                ])
        }
    }
    
    class func logVoiceOverSet(isSet:Bool){
        if AppConstants.isAppStore() {
            let defaults = UserDefaults.standard
            if isSet {
                defaults.set("yes", forKey: "isUsingVoiceOver")
                UserDefaults.standard.synchronize()
                Analytics.setUserProperty("yes", forName: "using_screen_reader")
            } else {
                defaults.set("no", forKey: "isUsingVoiceOver")
                UserDefaults.standard.synchronize()
                Analytics.setUserProperty("no", forName: "using_screen_reader")
            }
        }
    }
    
}
