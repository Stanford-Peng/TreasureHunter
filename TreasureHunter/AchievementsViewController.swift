//
//  AchievementsViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 20/11/20.
//

import UIKit
import FirebaseFirestore

class AchievementsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var earnedGoldLabel: UILabel!
    @IBOutlet weak var digCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var db = Firestore.firestore()
    var userReference = Firestore.firestore().collection("User")
    let reuseIdentifier = "leaderboardCell"
    var digsLeaderboard: [User] = []
    var goldLeaderboard: [User] = []
    // master array
    var displayedTable: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getCurrentUserAchievements()
        getTopUsers()
    }
    
    func getCurrentUserAchievements(){
        let email=UserDefaults.standard.string(forKey: "useremail")
        userReference.document(email!).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let user = User(name: data!["name"] as! String,
                                digCount: data!["digCount"] as! Int,
                                earnedGold: data!["earnedGold"] as! Int
                )
                self.configureLabel(label: self.digCountLabel, text: String(user.digCount!), iconName: "homeIcon")
                self.configureLabel(label: self.earnedGoldLabel, text: String(user.earnedGold!), iconName: "dollar")
                
                print("Document data: \(data!)")
            } else {
                print("User achievement document doesn't exist")
            }
        }
    }
    
    func getTopUsers(){
        //get top users by dig count
        db.collection("User").order(by: "digCount", descending: true).limit(to: 20)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        //                        print("\(document.documentID) => \(document.data())")
                        self.digsLeaderboard.append(User(
                            name: document.data()["name"] as! String,
                            score: document.data()["digCount"] as! Int
                        ))
                    }
                    self.updateTable()
                }
            }
        //get top userse by earned gold
        userReference.order(by: "earnedGold", descending: true).limit(to: 20)
        db.collection("User").order(by: "earnedGold", descending: true).limit(to: 20)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.goldLeaderboard.append(User(
                            name: document.data()["name"] as! String,
                            score: document.data()["earnedGold"] as! Int
                        ))
                    }
                }
            }
    }
    
    @IBAction func onSegmentToggle(_ sender: Any) {
        let index = segmentedControl.selectedSegmentIndex
        switch index {
        case 0: // index 0 = dig leaderboard
            displayedTable = digsLeaderboard
        case 1: // index 1 = gold leaderboard
            displayedTable = goldLeaderboard
        default:
            break
        }
        tableView.reloadData()
    }
    
    private func configureLabel(label: UILabel, text: String, iconName: String){
         // Create Attachment
         let imageAttachment = NSTextAttachment()
         imageAttachment.image = UIImage(named: iconName)
         // Set bound to reposition
         let imageOffsetY: CGFloat = -3.0
         imageAttachment.bounds = CGRect(x: -1, y: imageOffsetY, width: 20, height: 20)
         // Create string with attachment
         let attachmentString = NSAttributedString(attachment: imageAttachment)
         // Initialize mutable string
         let completeText = NSMutableAttributedString(string: "")
         // Add image to mutable string
         completeText.append(attachmentString)
         // Add your text to mutable string
         let textAfterIcon = NSAttributedString(string: text)
         completeText.append(textAfterIcon)
         label.textAlignment = .center
         label.attributedText = completeText
     }
    
    func updateTable(){
        displayedTable = digsLeaderboard
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        cell?.textLabel?.text = String(indexPath.row+1) + ". " + displayedTable[indexPath.row].name!
        var imageName = ""
        if segmentedControl.selectedSegmentIndex == 0 {
            imageName = "homeIcon"
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            imageName = "dollar"
        }
        self.configureLabel(label: cell!.detailTextLabel!, text: String(displayedTable[indexPath.row].score!), iconName: imageName)
        return cell!
    }
    
    
}
