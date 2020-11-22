//
//  SettingsViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import FirebaseFirestore



// Handles settings tab view
class SettingsViewController: UIViewController{
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var settingsTableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    var userReference = Firestore.firestore().collection("User")
    var optionsList = [String]()
    let userDefaults = UserDefaults.standard
    let reuseIdentifier = "SettingsCell"
    
    // Assign sensitive strings to variables to prevent typos
    struct Keys {
        static let username = "username"
        static let useremail = "useremail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    // Configure table view upon view load
    func configureTableView() {
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.rowHeight = 60
        
        settingsTableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(settingsTableView)
        settingsTableView.frame = view.frame
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        settingsTableView.tableHeaderView = userInfoHeader
        settingsTableView.tableFooterView = UIView()
    }
    
    
    func configureUI() {
        configureTableView()
        
        // Configure navigation bar
        navBar.prefersLargeTitles = true
        navBar.isTranslucent = false
        navBar.barStyle = .black
    }

    // Alert window that allows user input to process Feedback
    func promptForFeedback() {
        let ac = UIAlertController(title: "Leave Feedback", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [unowned ac] _ in
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0].text
            self.storeFeedback(feedback: answer!)
        }
        
        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    // Firebase function to store a user's feedback
    func storeFeedback(feedback: String){
        let email=UserDefaults.standard.string(forKey: "useremail")
        
        self.userReference.document(email!).collection("Feedback").addDocument(data: [
            "text": feedback,
            "time": Timestamp(date: Date.init())
        ])
        showToast(message: "Thank you for your feedback!", font: .systemFont(ofSize: 18))
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // Perform logout related functions
    func logoutTapped(){
        
        let ac = UIAlertController(title: "Confirm Logout", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let submitAction = UIAlertAction(title: "Log Out", style: .default) {_ in
            self.userDefaults.set("", forKey: Keys.username)
            self.userDefaults.set("", forKey: Keys.useremail)
            exit(0)
        }
        
        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        present(ac, animated: true)
        
        //Remove Username from User Defaults
//        userDefaults.set("", forKey: Keys.username)
//        userDefaults.set("", forKey: Keys.useremail)
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
//        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
        
    // Performs logout related functions
    @IBAction func logOut(_ sender: Any) {
        self.dismiss(animated: true) { [self] in
            self.userDefaults.set("", forKey: Keys.username)
            self.userDefaults.set("", forKey: Keys.useremail)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "achievementSegue" {
            let destinationVC = segue.destination as! AchievementsViewController
            destinationVC.modalPresentationStyle = .fullScreen
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = SettingsSection(rawValue: section) else {return 0}
        
        switch section {
        case .Profile: return ProfileOptions.allCases.count
        case .Application: return ApplicationOptions.allCases.count
        }
    }
    
    //User settings
    //reference: https://youtu.be/WqPoFzVrLj8
    // MARK: - Table view functions
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.Custom.darkBlue
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        title.text = SettingsSection(rawValue: section)?.description
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        
        guard let section = SettingsSection(rawValue: indexPath.section) else {return UITableViewCell()}
        
        switch section {
        case .Profile:
            let profile = ProfileOptions(rawValue: indexPath.row)
            cell.sectionType = profile
            
        case .Application:
            let application = ApplicationOptions(rawValue: indexPath.row)
            cell.sectionType = application
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else {return}
        
        switch section {
        case .Profile:
            if ProfileOptions(rawValue: indexPath.row)?.description == "Log Out"{
                logoutTapped()
                //userDefaults.synchronize()
//                break
//                self.dismiss(animated: true) {
//                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.logOut()
//               }
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
//                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
//                self.present(loginNavController, animated: true){
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
//                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
//                }
            }
            if ProfileOptions(rawValue: indexPath.row)?.description == "Leaderboard & Achievements"{
                performSegue(withIdentifier: "achievementSegue", sender: nil)
            }
            break

        case .Application:
            if ApplicationOptions(rawValue: indexPath.row)?.description == "Send Feedback" {
                promptForFeedback()
            }
        }
    }
}
