//
//  AppDelegate.swift
//  thetravelear
//
//  Created by Nicholas Culpin on 5/18/16.
//  Copyright © 2016 thetravelear. All rights reserved.
//

import UIKit
import BackgroundTasks
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDynamicLinks
import FirebaseAuth
import FirebaseFirestore
import FirebaseCrashlytics
import UserNotifications
import StoreKit
import CoreData
import GoogleCast
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate  {
    
    var window: UIWindow?
    private let appId = AppConstants.castRecieverAppID
    let gcmMessageIDKey = "gcm.message_id"
    let customURLScheme = AppConstants.bundleID
    let startTrackID = AppConstants.startTrackID
    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    var backgroundSessionCompletionHandler: (() -> Void)?
    var tracks = [Track]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        checkVersion()
        // Firebase
        FirebaseApp.configure()
        // deep links
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = self.customURLScheme
        // Products
        startIAP()
        // Notifications
        attemptRegisterForNotifications(application: application)
        // Google Cast
        setCast()
        // background tasks
        registerBackgroundTasks()
        // Set Crashlytics user
        Crashlytics.crashlytics().setUserID(Auth.auth().currentUser?.uid ?? "0")
        // Drawing
        self.window = UIWindow(frame: UIScreen.main.bounds)
        // set up new user data
        newUser()
        // verify email
        // checkVerifyEmail()
        // styles
        UINavigationBar.appearance().tintColor = UIColor.TravDarkBlue()
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        startInternetListener()
                
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // remove badges
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // this is for background downloads
        backgroundSessionCompletionHandler = completionHandler
    }
    
    // background tasks
    private func registerBackgroundTasks() {
        // TODO: HANDLE THESE
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.travelear.travel.refresh", using: nil) { task in }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.travelear.travel.cleanup", using: nil) { task in }
    }
    
    // MARK: STORE
    func startIAP(){
        SKPaymentQueue.default().add(IAPManager.shared)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(IAPManager.shared)
    }
    
    // MARK: CAST - Register
    func setCast(){
        // todo: replace kGCKDefaultMediaReceiverApplicationID w/ AppConstants.castRecieverAppID
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kGCKDefaultMediaReceiverApplicationID))
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)
        let logFilter = GCKLoggerFilter()
        logFilter.minimumLevel = .error
        GCKLogger.sharedInstance().filter = logFilter
        GCKLogger.sharedInstance().delegate = self
    }
    
    // MARK: CLOUD MESSAGING
    private func attemptRegisterForNotifications(application: UIApplication) {
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
            if let err = err {
                Crashlytics.crashlytics().record(error: err)
                print("pushnote - Failed to request auth:", err)
                return
            }
            if granted {
                print("pushnote - Auth granted.")
            } else {
                print("pushnote - Auth denied")
            }
        }
        
        application.registerForRemoteNotifications()
        
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("pushnote - Remote instance ID token: \(result.token)")
          }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken as Data
            print("pushnote - deviceTokenString = \(deviceToken.hexEncodedString())")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("pushnote - Registered with FCM with token:", fcmToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("pushnote - willPresent")  
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("pushnote - Message ID: \(messageID)")
        }
        print(userInfo)

        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([.sound,.alert,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("pushnote - didRecieve")
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("pushnote - Message ID: \(messageID)")
        }
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
    
    
    
    // MARK: CLOUD MESSAGING - END
    
    //MARK: Firebase Dynamic Links Start
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if dynamiclink != nil && error == nil {
                self.openDynamicLink(dynamiclink!)
            }
        }
        
        return handled
    }
    
    func openDynamicLink(_ dynamicLink: DynamicLink){
        let fullLink = dynamicLink.url?.pathComponents
        let linkPath = fullLink?[1]
        
        switch linkPath {
        case "share":
            let trackId = fullLink?[2]
            loadTrack(id: trackId ?? self.startTrackID)
        case "__":
            let link = dynamicLink.url!.absoluteString
            loadAuthentication(link: link)
        default: break
        }
    }
    
    // Firebase Dynamic Links End
    
    // MARK: USER DATA
    func loadAuthentication(link:String) {

        let defaults = UserDefaults.standard
        guard let email = defaults.object(forKey: "Email") as? String else {return}
        
        Auth.auth().signIn(withEmail: email, link: link) { (user, error) in
            
            if error != nil {
                
                defaults.setValue(false, forKey: "isLoggedIn")
                defaults.removeObject(forKey: "link")
                defaults.removeObject(forKey: "email")
                defaults.synchronize()
                
            } else {
                
                defaults.setValue(true, forKey: "isLoggedIn")
                defaults.synchronize()
                
                let user = Auth.auth().currentUser
                let uid = user!.uid
                
                let db = Firestore.firestore()
                let joinDate = Timestamp()
                
                db.collection("users").document(uid).setData([
                    "email": "\(email)",
                    "firstName" : " ",
                    "lastName" : " ",
                    "bio": " ",
                    "location" : " ",
                    "profileImage" : " ",
                    "id": uid,
                    "joined" : joinDate,
                    "birthday": " ",
                    "subscription_nickname": "",
                    "subscription_active" : "inactive",
                    "subscription_period_start" : Timestamp(),
                    "subscription_period_end": Timestamp(),
                    "favorites": [],
                    "role" : "user",
                    ])
                
                let defaults = UserDefaults.standard
                defaults.setValue(true, forKey: "isLoggedIn")
                defaults.removeObject(forKey: "link")
                defaults.synchronize()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"checkChangesAuth"), object: nil)

            }
        }
    }
    
    func newUser(){
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.bool(forKey: "isLoggedIn")
        if isLoggedIn  {
            self.keyLastTrackAndView()
        } else {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if error != nil {
                    Crashlytics.crashlytics().record(error: error!)
                } else {
                    
                    let user = Auth.auth().currentUser
                    let uid = user!.uid
                    
                    let db = Firestore.firestore()
                    let joinDate = Timestamp()
                    
                    db.collection("users").document(uid).setData([
                        "email": " ",
                        "firstName" : " ",
                        "lastName" : " ",
                        "bio": " ",
                        "location" : " ",
                        "profileImage" : " ",
                        "id": uid,
                        "joined" : joinDate,
                        "birthday": " ",
                        "subscription_nickname": "",
                        "subscription_active" : "inactive",
                        "subscription_period_start" : Timestamp(),
                        "subscription_period_end": Timestamp(),
                        "favorites": [],
                        "role" : "user",
                        ])

                    self.keyLastTrackAndView()
                }
            })
        }
    }

    func checkVerifyEmail(){
        //if user is logged in
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.bool(forKey: "isLoggedIn")
        if isLoggedIn  {
            let verified = Auth.auth().currentUser!.isEmailVerified
            // could be possible to get a non-Bool from old users so convert to Int
            var verifiedToInt = 0
            if verified {
                verifiedToInt = 1
            }
            
            if (verifiedToInt == 1) {
                return
            } else {
                let alert = UIAlertController(title: "Oops!", message: "Please check your email to verify sign up.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                let resendAction = UIAlertAction(title: "Resend", style: .default, handler: {
                    _ in self.resendVerifyEmail()
                })
                alert.addAction(okAction)
                alert.addAction(resendAction)
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func resendVerifyEmail(){
        // could have another dialog on success but maybe it's too many popups
        // Also a second popup could just use this to block further access right here
        // make that decision later. For now, pass.
        Auth.auth().currentUser!.sendEmailVerification()
    }
    
    func keyLastTrackAndView(){
        loadLastKnownTrack()
        self.window?.rootViewController = HomeViewController()
        self.window?.makeKeyAndVisible()
    }
    
    func loadTrack(id: String){
        API.getTrack(id: id) { (track) in
            PlayerService.sharedInstance.load(creatorName:track.creatorName!, creatorImage: track.creatorImage!, isPublic:track.isPublic!,author:track.author!, duration:track.duration!, file:track.file!, image:track.image!, latitude:track.latitude!, longitude: track.longitude!, location:track.location!, id:track.id!, name:track.name!, recorded:track.recorded!, tags:track.tags!, timestamp:track.timestamp!, status:false, isMonetized: track.isMonetized!, isWorld:track.isWorld!, isSleep:track.isSleep!)
        }
    }
    
    func loadLastKnownTrack(){
        self.loadTrack(id: self.startTrackID)
    }
    
    func checkVersion(){
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        let buildVersionString = "\(build)-\(version)"
        if buildVersionString == "\(AppConstants.mandatoryBuild)-\(AppConstants.mandatoryVersion)" {
            
            // RESET DEFAULTS
            UserDefaults.standard.resetDefaults()
            
            // RESET CORE DATA
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext

            if checkIfEntityExist(entity: "FavoriteTrack") == true {
                let deleteFavoriteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteTrack")
                let deleteFavoriteRequest = NSBatchDeleteRequest(fetchRequest: deleteFavoriteFetch)
                do {
                    try context.execute(deleteFavoriteRequest)
                    try context.save()
                } catch {
                    print ("reset: there was an error")
                }
            }
  
        } else {
            print("reset: you are up to date")
        }
    }
    
    func checkIfEntityExist(entity:String)->Bool{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.fetchLimit =  1
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                return true
            }else {
                return false
            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "thetravelear")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                Crashlytics.crashlytics().record(error: error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                Crashlytics.crashlytics().record(error: error)
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

// MARK: Reachability
extension AppDelegate: ReachabilityObserverDelegate {
    
    func startInternetListener(){
        try? addReachabilityObserver()
    }
    
    func endInternetListener(){
        removeReachabilityObserver()
    }
    
    func reachabilityChanged(_ isReachable: Bool) {
        if !isReachable {
            NotificationCenter.default.post(name: .ReachabilityNotification, object: false)
            Alerts.showNoInternet()
        } else {
            NotificationCenter.default.post(name: .ReachabilityNotification, object: true)
            IAPManager.shared.verify() // Verify Purchases on internet change
        }
    }
}

// MARK: Google Cast Log
extension AppDelegate: GCKLoggerDelegate {
    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        print("cast: message = \(message), level = \(level), fromFunction = \(function), location = \(location)")
    }
}

// MARK: - GCKSessionManagerListener

extension AppDelegate: GCKSessionManagerListener {
  func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
    if error == nil {
        print("cast : session ended")
    } else {
        Crashlytics.crashlytics().record(error: error!)
      let message = "cast : Session ended unexpectedly:\n\(error?.localizedDescription ?? "")"
      print("cast : \(message)")
    }
  }

  func sessionManager(_: GCKSessionManager, didFailToStart _: GCKSession, withError error: Error) {
    Crashlytics.crashlytics().record(error: error)
    let message = "cast : Failed to start session:\n\(error.localizedDescription)"
    print("cast : \(message)")
  }
}
