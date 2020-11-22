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
        return 3
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
        
        if section == 2{
            sections = groups.count
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
        if indexPath.section == 2{
            let group = groups[indexPath.row]
            cell.textLabel?.text = group.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0
        {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // for delete contact
        if indexPath.section == 1{
            if editingStyle == .delete {
                // Delete the row from the data source
                let alert = UIAlertController(title: "Alert", message: "Do you want to delete", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                    //self.databaseController?.deleteExhibition(exhibition: self.allExhibitions[indexPath.row])
                    //delete from the other side
                    self.contactsRef?.document(self.contacts[indexPath.row].id).collection("friends").document(self.currentSender!.senderId).delete(completion: { (error) in
                        if let error = error {
                            print(error)
                            self.showAlert(title: "Database Error", message: "Failed")
                            return
                        }
                        //delete from own list
                        self.userContactsDoc?.document(self.contacts[indexPath.row].id).delete(completion: { (error) in
                            if let error = error {
                                print(error)
                                self.showAlert(title: "Database Error", message: "Failed")
                                return
                            }
                            self.showAlert(title: "Successful", message: "This friend is removed from your list")
                        })
                    })
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //            var _:(ACTION) -> Void =  { (action) -> Void in
                //                    self.databaseController?.deleteExhibition(exhibition: self.allExhibitions[indexPath.row])
                //            }
                //tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
        
        //for delete group
        if indexPath.section == 2{
            if editingStyle == .delete {
                let alert = UIAlertController(title: "Alert", message: "Do you want to leave the group", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                    self.privateChannelRef?.document(self.groups[indexPath.row].id).collection("members").getDocuments(completion: { (querySnapshot, error) in
                        if let error = error{
                            print(error)
                            return
                        }
                        //delete the whole group as well as from user group list
                        if querySnapshot?.count == 1 {
                            
                            self.privateChannelRef?.document(self.groups[indexPath.row].id).delete(completion: { (error) in
                                //embedded collection not deleted
                                if let error = error{
                                    print(error)
                                    return
                                    
                                }
                                self.groupsRef?.document(self.groups[indexPath.row].id).delete(completion: { (error) in
                                    if let error = error{
                                        print(error)
                                        return
                                    }
                                    
                                    self.showAlert(title: "Successful", message: "You are the last member so that the group is destroyed")
                                    
                                })
                                
                            })
                        }
                        //only delete from group members and user's group list
                        else if querySnapshot!.count > 1{
                            self.privateChannelRef?.document(self.groups[indexPath.row].id).collection("members").document(self.currentSender!.senderId).delete(completion: { (error) in
                                if let error = error{
                                    print(error)
                                    return
                                    
                                }
                                self.groupsRef?.document(self.groups[indexPath.row].id).delete(completion: { (error) in
                                    self.showAlert(title: "Successful", message: "You have left the group!")
                                })
                            })
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
        
    }
    //different options for selecting a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let channel = channels[indexPath.row]
            performSegue(withIdentifier:CHANNEL_SEGUE, sender: channel)
        }
        
        if indexPath.section == 1{
            let contact = contacts[indexPath.row]
            performSegue(withIdentifier:CHANNEL_SEGUE, sender: contact)
        }
        
        if indexPath.section == 2 {
            let group = groups[indexPath.row]
            performSegue(withIdentifier:CHANNEL_SEGUE, sender: group)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // Create a standard header that includes the returned text.
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection
    //                                section: Int) -> String? {
    //        if section == 0
    //        {
    //            return "Groups: "
    //        }
    //
    //       return "Friends: "
    //    }
    
    //create header for different table sections
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
        if section == 0{
            title.text = "Public Chat Rooms"
        }
        if section == 1{
            title.text = "Your Private Friends"
        }
        if section == 2{
            title.text = "Your Private Groups"
        }
        return view
    }
    
    // Create a standard footer that includes the returned text.
    func tableView(_ tableView: UITableView, titleForFooterInSection
                    section: Int) -> String? {
        var footer:String?
        if section == 0{
            footer = "\(channels.count) groups"
        }
        if section == 1{
            footer = "\(contacts.count) friends"
        }
        if section == 2{
            footer = "\(groups.count) private groups"
        }
        return footer!
    }
    
    //Prettify user interface
    func configureUI() {
        chatNavBar.prefersLargeTitles = true
        chatNavBar.isTranslucent = false
        chatNavBar.barStyle = .black
    }
    
    let CHANNEL_CELL = "channelCell"
    var currentSender: Sender?
    var channels = [Channel]()
    var contacts = [Contact]()
    var groups = [Group]()
    var channelsRef: CollectionReference?
    var contactsRef: CollectionReference?
    var groupsRef: CollectionReference?
    var privateChannelRef: CollectionReference?
    var userContactsDoc:CollectionReference?
    let CHANNEL_SEGUE = "goToChannel"
    //listener coming with firebase
    var databaseListener: ListenerRegistration?
    let database = Firestore.firestore()
    @IBOutlet weak var channelTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        let username = UserDefaults.standard.string(forKey: "username")
        let email=UserDefaults.standard.string(forKey: "useremail")
        channelsRef = database.collection("channels")
        contactsRef = database.collection("contacts")
        groupsRef = database.collection("User").document(email!).collection("groups")
        privateChannelRef = database.collection("PrivateChannel")
        //navigationItem.title = "Channels"
        
        
        currentSender = Sender(id:email!,name:username!)
        
        // Do any additional setup after loading the view.
        
        channelTable.dataSource = self
        channelTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //get public chat room channels
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
            self.channelTable.reloadSections([0], with: .fade)
            
        }
        
        //get user contacts
        let email=UserDefaults.standard.string(forKey: "useremail")
        userContactsDoc=contactsRef?.document(email!).collection("friends")
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
        
        //get users private room channels
        databaseListener = groupsRef?.addSnapshotListener({ (querySnapshot, error) in
            if let error = error {
                print(error)
                return
                
            }
            self.groups.removeAll()
            querySnapshot?.documents.forEach({ (snapshot) in
                let id = snapshot.documentID
                let name = snapshot["name"] as! String
                let group = Group(id: id, name: name)
                
                self.groups.append(group)
            })
            self.channelTable.reloadSections([2], with: .fade)
            
            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    
    //present an action sheet:Add a channel / Add a Contact
    @IBAction func addAction(_ sender: Any) {
        
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
            popover.barButtonItem = sender
            //actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        self.present(actionSheet, animated: true)
        
        
    }
    
    //Add a chat contact for user
    func addContact(){
        let alertController = UIAlertController(title: "Add New Friend", message: "Enter the player's ID(email) below", preferredStyle: .alert)
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let email=UserDefaults.standard.string(forKey: "useremail")
        let username = UserDefaults.standard.string(forKey: "username")
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            let contactEmail = alertController.textFields![0]
            var doesExist = false
            for contact in self.contacts {
                if contact.id == contactEmail.text!.lowercased() {
                    self.showAlert(title: "Warning", message: "It is in your contact list")
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
                        
                        //add from request side
                        self.contactsRef?.document(email!).collection("friends").document(queryDocumentSnapshot.documentID).setData(["name":queryDocumentSnapshot["name"]!])
                        //add from the receiving side
                        self.contactsRef?.document(queryDocumentSnapshot.documentID).collection("friends").document(email!).setData(["name":username!])
                        doesExist=true
                    }
                })
                
                
                if !doesExist {
                    self.showAlert(title: "Warning", message: "No Such User")
                    
                }else{
                    self.showAlert(title: "Added", message: "Add one firend")
                }
            }
            
            
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true)
    }
    
    //create channel for user
    func addChannel(){
        let email=UserDefaults.standard.string(forKey: "useremail")
        let username = UserDefaults.standard.string(forKey: "username")
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
            
            for channel in self.groups {
                if channel.name.lowercased() == channelName.text!.lowercased() {
                    doesExist = true
                }
                
            }
            if !doesExist {
                let doc = self.groupsRef?.addDocument(data: [ "name" : channelName.text! ])
                self.privateChannelRef?.document(doc!.documentID).setData(["name":channelName.text!])
                self.privateChannelRef?.document(doc!.documentID).collection("members").document(email!).setData(["name":username!])
                //self.channelsRef?.addDocument(data: ["name" : channelName.text!])
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
    
    //prepare settings for different chattings: public room, contact chatting or private room chatting
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == CHANNEL_SEGUE {
            
            if let channel = sender as? Channel{
                let destinationVC = segue.destination as! ChannelMessagesViewController
                //destinationVC.modalPresentationStyle = .fullScreen
                destinationVC.sender = currentSender
                destinationVC.currentChannel = channel
                destinationVC.currentContact = Optional.none
                destinationVC.currentGroup = Optional.none
            }else if let contact = sender as? Contact{
                let destinationVC = segue.destination as! ChannelMessagesViewController
                destinationVC.sender = currentSender
                destinationVC.currentContact = contact
                destinationVC.currentChannel = Optional.none
                destinationVC.currentGroup = Optional.none
            } else if let group = sender as? Group{
                let destinationVC = segue.destination as! ChannelMessagesViewController
                destinationVC.sender = currentSender
                destinationVC.currentGroup = group
                destinationVC.currentChannel = Optional.none
                destinationVC.currentContact = Optional.none
            }
            
        }
    }
    
}
