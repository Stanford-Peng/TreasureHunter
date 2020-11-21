//
//  AchievementsViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 20/11/20.
//

import UIKit

class AchievementsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var earnedGoldLabel: UILabel!
    @IBOutlet weak var digCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let reuseIdentifier = "leaderboardCell"
    var digsLeaderboard: [User] = []
    var goldLeaderboard: [User] = []
    // master array
    var displayedTable: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureUI()
        tableView.reloadData()
    }
    
    func configureUI(){
        //temporary users for testing
        digsLeaderboard.append(User(name: "Alston", score: 5))
        digsLeaderboard.append(User(name: "Stan", score: 10))
        goldLeaderboard.append(User(name: "Bob", score: 2))
        goldLeaderboard.append(User(name: "Jack", score: 99))
        digsLeaderboard.sort(by: {$0.score! > $1.score!})
        goldLeaderboard.sort(by: {$0.score! > $1.score!})
        displayedTable = digsLeaderboard
    }
    
    // MARK: - Navigation
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    // MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        cell?.textLabel?.text = String(indexPath.row+1) + ". " + displayedTable[indexPath.row].name!
        cell?.detailTextLabel?.text = String(displayedTable[indexPath.row].score!)
        return cell!
    }
}
