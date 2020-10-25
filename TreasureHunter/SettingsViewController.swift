//
//  SettingsViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingsTableView: UITableView!
    var optionsList = [String]()
    let userDefaults = UserDefaults.standard

    struct Keys {
        static let username = "username"
        static let useremail = "useremail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsList.append("Log Out");
        
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
    
    // MARK: - Table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        let option = optionsList[indexPath.row]
        
        print(option)
        
        cell.textLabel?.text = option;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (optionsList[indexPath.row] == "Log Out"){
            logoutTapped()
        }
    }
    
    func logoutTapped(){
        // Perform logout related functions
        
        //Remove Username from User Defaults
        userDefaults.set("", forKey: Keys.username)
        userDefaults.set("", forKey: Keys.useremail)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
   
   
}
