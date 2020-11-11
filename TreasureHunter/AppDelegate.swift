//
//  AppDelegate.swift
//  TreasureHunter
//
//  Created by Stanford on 23/10/20.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseFirestore

//UI color guideline:https://uxplanet.org/best-three-color-scheme-for-music-player-5da996d7f460
@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UIWindowSceneDelegate{
    
    var window: UIWindow?
    var itemFunctionsController = ItemFunctionsController()
    //var seconds = 180
    //for google sign
    //https://www.youtube.com/watch?v=20Qlho0G3YQ&t=669s
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let _ = error {
                //present an alert window
                return
            }
            self.goToHome(user: user)
            //sign in
        }

    }
    
    func goToHome(user: GIDGoogleUser){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }
        self.window = sceneDelegate.window
        let email = user.profile.email
        let name = user.profile.name
        //let uuid = user.userID
        print("\(email ?? "No Email")")
        print("\(name ?? "No Name")")
        
        UserDefaults.standard.set(email, forKey: "useremail")
        UserDefaults.standard.set(name, forKey: "username")
        
        let userReference = Firestore.firestore().collection("User")
        userReference.document(email!).setData(["name":name ?? ""], merge: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
        
        sceneDelegate.changeRootViewController(mainTabBarController)
    }
    
    
    //for opening url(goole sign in web interface)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance()?.clientID = "1026623119501-db5uqnrsqpdae01qm2l710o9fpvvi6cf.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // if user == logged in {
        //      send seconds information to server
        //}
    }
    
//    func displayErrorMessage(_ errorMessage: String) {
//        let alertController = UIAlertController(title: "Error", message:errorMessage, preferredStyle: UIAlertController.Style.alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//
//    }
}

