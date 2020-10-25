//
//  SettingsViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController{
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var settingsTableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    
    var optionsList = [String]()
    let userDefaults = UserDefaults.standard
    
    struct Keys {
        static let username = "username"
        static let useremail = "useremail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        //        optionsList.append("Log Out");
        // Do any additional setup after loading the view.
    }
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
        
        navBar.prefersLargeTitles = true
        navBar.isTranslucent = false
        navBar.barStyle = .black
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
    
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return optionsList.count
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
    //        let option = optionsList[indexPath.row]
    //
    //        print(option)
    //
    //        cell.textLabel?.text = option;
    //        return cell
    //    }
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        if (optionsList[indexPath.row] == "Log Out"){
    //            logoutTapped()
    //        }
    //    }
    //
    //    func logoutTapped(){
    //        // Perform logout related functions
    //
    //        //Remove Username from User Defaults
    //        userDefaults.set("", forKey: Keys.username)
    //        userDefaults.set("", forKey: Keys.useremail)
    //
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavController")
    //        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    //    }    
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemBlue
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
            cell.textLabel?.text = profile?.description
        case .Application:
            let application = ApplicationOptions(rawValue: indexPath.row)
            cell.textLabel?.text = application?.description
        }
        return cell
    }
    
}
