//
//  ChatViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import FirebaseFirestore
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //configure data source and table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHANNEL_CELL, for: indexPath)
        let channel = channels[indexPath.row]
        cell.textLabel?.text = channel.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        performSegue(withIdentifier:CHANNEL_SEGUE, sender: channel)
        
    }

    let CHANNEL_CELL = "channelCell"
    var currentSender: Sender?
    var channels = [Channel]()
    var channelsRef: CollectionReference?
    let CHANNEL_SEGUE = "goToChannel"
    //listener coming with firebase
    var databaseListener: ListenerRegistration?
    
    @IBOutlet weak var channelTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let database = Firestore.firestore()
        channelsRef = database.collection("channels")
        //navigationItem.title = "Channels"
        
        let username = UserDefaults.standard.string(forKey: "username")
        let email=UserDefaults.standard.string(forKey: "useremail")
        currentSender = Sender(id:email!,name:username!)
        
        // Do any additional setup after loading the view.
        
        channelTable.dataSource = self
        channelTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseListener = channelsRef?.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
                
            }
            self.channels.removeAll()
            querySnapshot?.documents.forEach({snapshot in
                let id = snapshot.documentID
                let name = snapshot["name"] as! String
                let channel = Channel(id: id, name: name)
                self.channels.append(channel)
                
            })
            self.channelTable.reloadData()
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    
    
    @IBAction func addChannel(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Channel", message: "Enter channel name below", preferredStyle: .alert)
        
        //add text field
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            let channelName = alertController.textFields![0]
            var doesExist = false
            for channel in self.channels {
                if channel.name.lowercased() == channelName.text!.lowercased() {
                    doesExist = true
                }
                
            }
            if !doesExist {
                self.channelsRef?.addDocument(data: [ "name" : channelName.text! ])
            }
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == CHANNEL_SEGUE {
            let channel = sender as! Channel
            let destinationVC = segue.destination as! ChannelMessagesViewController
            destinationVC.sender = currentSender
            destinationVC.currentChannel = channel
            
        }
    }

}
