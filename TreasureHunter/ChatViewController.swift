//
//  ChatViewController.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 24/10/20.
//

import UIKit
import FirebaseFirestore
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chatNavBar: UINavigationBar!
    //configure data source and table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var sections:Int?
        if section == 0{
            sections = channels.count
        }
        if section == 1{
            sections = contacts.count
        }
        return sections!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHANNEL_CELL, for: indexPath)
        if indexPath.section == 0{
            let channel = channels[indexPath.row]
            cell.textLabel?.text = channel.name
        }
        if indexPath.section == 1 {
            let contact = contacts[indexPath.row]
            cell.textLabel?.text = contact.name
        }
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
    
    func configureUI() {
        chatNavBar.prefersLargeTitles = true
        chatNavBar.isTranslucent = false
        chatNavBar.barStyle = .black
    }

    let CHANNEL_CELL = "channelCell"
    var currentSender: Sender?
    var channels = [Channel]()
    var contacts = [Contact]()
    var channelsRef: CollectionReference?
    var contactsRef: CollectionReference?
    let CHANNEL_SEGUE = "goToChannel"
    //listener coming with firebase
    var databaseListener: ListenerRegistration?
    
    @IBOutlet weak var channelTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        let database = Firestore.firestore()
        channelsRef = database.collection("channels")
        contactsRef = database.collection("contacts")
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
        let email=UserDefaults.standard.string(forKey: "useremail")
        let userContactsDoc=contactsRef?.document(email!).collection("friends")
        
        databaseListener = userContactsDoc?.addSnapshotListener({ (querySnapshot, error) in
            if let error = error {
                print(error)
                return
                
            }
            self.contacts.removeAll()
            querySnapshot?.documents.forEach({ (queryDocumentSnapshot) in
                let id = queryDocumentSnapshot.documentID
                let name = queryDocumentSnapshot["name"] as! String
                let contact = Contact(id: id, name: name)
                self.contacts.append(contact)
                
                
            })
            
            self.channelTable.reloadSections([1], with: .fade)
        }
        )
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    
    
    @IBAction func addChannel(_ sender: Any) {
        let sender = sender as? UIBarButtonItem
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let addChanel = UIAlertAction(title: "Add a Channel", style: .default) { (_) in
            self.addChannel()
        }
        let addContact = UIAlertAction(title: "Add a Contact", style: .default){ _ in
            
            self.addContact()
        }
        actionSheet.addAction(addChanel)
        actionSheet.addAction(addContact)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        actionSheet.popoverPresentationControlle
        if let popover = actionSheet.popoverPresentationController{
            actionSheet.popoverPresentationController?.barButtonItem = sender
            //actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        self.present(actionSheet, animated: true)
        

    }
    func addContact(){
        let alertController = UIAlertController(title: "Add New Friend", message: "Enter the player's ID(email) below", preferredStyle: .alert)
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            let contactEmail = alertController.textFields![0]
            var doesExist = false
            for contact in self.contacts {
                if contact.id == contactEmail.text!.lowercased() {
                    self.showAlert(title: "Waring", message: "It is in your contacts")
                }
                
            }
            let userRef = Firestore.firestore().collection("User")
            userRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                    return
                    
                }
                querySnapshot?.documents.forEach({ (queryDocumentSnapshot) in
                    if queryDocumentSnapshot.documentID == contactEmail.text!.lowercased(){
                        self.contactsRef?.document(queryDocumentSnapshot.documentID).setData([:])
                        doesExist=true
                    }
                })
                if !doesExist {
                    self.showAlert(title: "Waring", message: "No Such User")

                }
            }
            
            
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true)
    }
    
    func addChannel(){
        let alertController = UIAlertController(title: "Add New Channel", message: "Enter channel name below", preferredStyle: .alert)
        //add text field
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            let channelName = alertController.textFields![0]
            
            if channelName.text!.count < 3{
                self.showAlert(title: "Warning", message: "The channel name has to be more than 3 Characters")
                return
            }
            
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
