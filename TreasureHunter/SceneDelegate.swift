//
//  SceneDelegate.swift
//  TreasureHunter
//
//  Created by Stanford on 23/10/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    
    var window: UIWindow?
    //var seconds: Int?
    var leftSeconds:Int?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        
        // CHANGE ROOT VIEW CONTROLLER TO TAB BAR CONTROLLER IF USER IS ALREADY LOGGED IN (https://fluffy.es/how-to-transition-from-login-screen-to-tab-bar-controller/)
        // Get storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loggedUsername = UserDefaults.standard.string(forKey: "username")
        
        if (loggedUsername != nil && loggedUsername != ""){
            // if user is logged in            
            // instantiate the main tab bar controller and set it as root view controller
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            window?.rootViewController = mainTabBarController
        } else {
            // if user isn't logged in
            // instantiate the navigation controller and set it as root view controller
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
            window?.rootViewController = loginNavController
        }
        
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
          .requestAuthorization(options: options) { success, error in
            if let error = error {
              print("Error: \(error)")
            }
        }
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        window.rootViewController = vc
        // add animations
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [.transitionCurlDown],
                          animations: nil,
                          completion: nil)
    }
    
    func logOut(){
//        let userDefaults = UserDefaults.standard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
//        userDefaults.set("", forKey: Keys.username)
//        userDefaults.set("", forKey: Keys.useremail)
        guard let window = self.window else {
            return
        }
        window.rootViewController = loginNavController
        // add animations
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [.transitionCurlDown],
                          animations: nil,
                          completion: nil)
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        //if user log in, get timedate from firebase and calculate the left time
        
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        //If scene is active, there is no need to use notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//        NotificationCenter.default.removeObserver(self)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)

//        NotificationCenter.default.addObserver(self, selector: #selector(notify), name: Notification.Name("CanDig"),object: nil)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let popVC = storyboard.instantiateViewController(identifier: "PopVC") as! GroupMemberController
        
        //
        if !UserDefaults.standard.bool(forKey: "notifications") {
            return
        }
        
        //if user is logged in and left time is > 0, schedule a notification
        if UserDefaults.standard.string(forKey: "useremail") != "" && UserDefaults.standard.string(forKey: "useremail") != nil{
            let tabController = window!.rootViewController as! UITabBarController
            let homeViewController = tabController.viewControllers?.first as! HomeViewController
            
            leftSeconds = homeViewController.seconds
            print("async start")

            if leftSeconds! > 0{
                self.notify(interval: leftSeconds!)
            }
        }
        
        
        
        //        DispatchQueue.global(qos:.background).asyncAfter(deadline: .now() + Double(leftSeconds!)) {
        //            self.notify()
        //        }
    }
    
    
}

extension SceneDelegate{
    //reference: https://www.hackingwithswift.com/example-code/system/how-to-run-code-when-your-app-is-terminated
    //https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications
    @objc func notify(interval:Int){
        print("notified")
        
        if UIApplication.shared.applicationState == .active {
          //window?.rootViewController?.showAlert(title: "Attention", message: message)
            //when window is active, do nothing
            print("active")
        } else {
            print("background")
            let message:String = "You can dig now!"
          // Otherwise present a local notification
          let notificationContent = UNMutableNotificationContent()
          notificationContent.body = message
          notificationContent.sound = UNNotificationSound.default
          //notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
          
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(interval), repeats: false)
          let request = UNNotificationRequest(identifier: "can_dig",
                                              content: notificationContent,
                                              trigger: trigger)
          UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
              print("Error: \(error)")
            }
          }
        }
    }
}
