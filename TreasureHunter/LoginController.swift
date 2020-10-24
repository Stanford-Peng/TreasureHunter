//
//  LoginController.swift
//  TreasureHunter
//
//  Created by Stanford on 24/10/20.
//

import UIKit
import GoogleSignIn
class LoginController: UIViewController {
    
    @IBOutlet var signINButton:GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background-login")!)
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        
        
//        if GIDSignIn.sharedInstance()?.currentUser != nil{
//
//        }else{
//            //silent sign in
//            GIDSignIn.sharedInstance()?.signIn()
//        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
