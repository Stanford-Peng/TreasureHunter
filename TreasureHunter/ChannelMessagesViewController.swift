//
//  ChannelMessagesViewController.swift
//  TreasureHunter
//
//  Created by Stanford on 26/10/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChannelMessagesViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var sender: Sender?
    var currentChannel: Channel?
    var currentContact: Contact?
    var currentGroup:Group?
    var messagesList = [ChannelMessage]()
    
    var channelRef: CollectionReference?
    var contactRef: CollectionReference?
    var privateChannelRef: CollectionReference?
    var groupMembers:[Contact] = [Contact]()
    var databaseListener: ListenerRegistration?
    var viewItem:UIBarButtonItem?
    let database = Firestore.firestore()
    @IBOutlet weak var navBar: UINavigationBar!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navBar)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messagesCollectionView.contentInset = UIEdgeInsets(top: navBar.frame.size.height, left: 0, bottom: 0, right: 0)
        // Do any additional setup after loading the view.
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messageInputBar.delegate = self
        

        
        //view.addSubview(navBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if currentChannel != nil {
            channelRef = database.collection("channels").document(currentChannel!.id).collection("messages")
            navBar.topItem?.title = "\(currentChannel!.name)"
            //navigationItem.title = "\(currentChannel!.name)"
            databaseListener = channelRef?.order(by: "time").addSnapshotListener { (querySnapshot, error) in
                if error != nil {
                    print(error!)
                    return
                    
                }
                querySnapshot?.documentChanges.forEach({change in
                    if change.type == .added{
                        let snapshot = change.document
                        let id = snapshot.documentID
                        let senderId = snapshot["senderId"] as! String
                        let senderName = snapshot["senderName"] as! String
                        let messageText = snapshot["text"] as! String
                        let sentTimestamp = snapshot["time"] as! Timestamp
                        let sentDate = sentTimestamp.dateValue()
                        let sender = Sender(id: senderId, name: senderName)
                        let message = ChannelMessage(sender: sender, messageId: id, sentDate: sentDate, message: messageText)
                        
                        if !self.messagesList.contains(where: { (m) -> Bool in
                            return message == m
                        })
                        {
                            self.messagesList.append(message)
                            self.messagesCollectionView.insertSections([self.messagesList.count-1])
                        }
                        
                    }
                    
                })
                self.messagesCollectionView.scrollToBottom()
                
            }
        }
        
        if currentContact != nil {
            contactRef = database.collection("contacts").document(sender!.senderId).collection("friends").document(currentContact!.id).collection("messages")
            navBar.topItem?.title = "\(currentContact!.name)"
            
            databaseListener = contactRef?.order(by:"time").addSnapshotListener({ (querySnapshot, error) in
                if error != nil {
                    print(error!)
                    return
                    
                }
                querySnapshot?.documentChanges.forEach({change in
                    if change.type == .added{
                        let snapshot = change.document
                        let id = snapshot.documentID
                        let senderId = snapshot["senderId"] as! String
                        let senderName = snapshot["senderName"] as! String
                        let messageText = snapshot["text"] as! String
                        let sentTimestamp = snapshot["time"] as! Timestamp
                        let sentDate = sentTimestamp.dateValue()
                        let sender = Sender(id: senderId, name: senderName)
                        let message = ChannelMessage(sender: sender, messageId: id, sentDate: sentDate, message: messageText)
                        
                        if !self.messagesList.contains(where: { (m) -> Bool in
                            return message == m
                        })
                        {
                            self.messagesList.append(message)
                            self.messagesCollectionView.insertSections([self.messagesList.count-1])
                        }
                        
                    }
                    
                })
                self.messagesCollectionView.scrollToBottom()
            })
        }
        
        if currentGroup != nil{
            privateChannelRef = database.collection("PrivateChannel")
            let messageRef = privateChannelRef?.document(currentGroup!.id).collection("messages")
            navBar.topItem?.title = "\(currentGroup!.name)"
            let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
            viewItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(viewMembers))
            navBar.topItem?.rightBarButtonItems = [viewItem!, addItem]
            //navBar
//            let navItem = UINavigationItem()
//            navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
//            navBar.items?.append(navItem)
            databaseListener = messageRef?.order(by: "time").addSnapshotListener { (querySnapshot, error) in
                if error != nil {
                    print(error!)
                    return
                    
                }
                querySnapshot?.documentChanges.forEach({change in
                    if change.type == .added{
                        let snapshot = change.document
                        let id = snapshot.documentID
                        let senderId = snapshot["senderId"] as! String
                        let senderName = snapshot["senderName"] as! String
                        let messageText = snapshot["text"] as! String
                        let sentTimestamp = snapshot["time"] as! Timestamp
                        let sentDate = sentTimestamp.dateValue()
                        let sender = Sender(id: senderId, name: senderName)
                        let message = ChannelMessage(sender: sender, messageId: id, sentDate: sentDate, message: messageText)
                        
                        if !self.messagesList.contains(where: { (m) -> Bool in
                            return message == m
                        })
                        {
                            self.messagesList.append(message)
                            self.messagesCollectionView.insertSections([self.messagesList.count-1])
                        }
                        
                    }
                    
                })
                self.messagesCollectionView.scrollToBottom()
                
            }
        }

    }
    
    @objc func addFriend(){
        
        let alertController = UIAlertController(title: "Add New Friend to Group", message: "Enter the player's ID(email) below", preferredStyle: .alert)
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let email=UserDefaults.standard.string(forKey: "useremail")
//        let username = UserDefaults.standard.string(forKey: "username")
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            let contactEmail = alertController.textFields![0]
            var doesExist = false
            
            
//            for contact in self.contacts {
//                if contact.id == contactEmail.text!.lowercased() {
//                    self.showAlert(title: "Waring", message: "It is in your contacts")
//                }
//
//            }
            let userRef = Firestore.firestore().collection("User")
            
            userRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                    return
                    
                }
                querySnapshot?.documents.forEach({ (queryDocumentSnapshot) in
                    
                    if queryDocumentSnapshot.documentID == contactEmail.text!.lowercased(){
                        //add to user group
                        userRef.document(queryDocumentSnapshot.documentID).collection("groups").document(self.currentGroup!.id).setData(["name":self.currentGroup!.name])
                        //add to group memebr
                        self.privateChannelRef?.document(self.currentGroup!.id).collection("members").document(queryDocumentSnapshot.documentID).setData(["name":queryDocumentSnapshot.get("name") as! String])
                        
                        doesExist=true
                    }
                })
                
                
                if !doesExist {
                    self.showAlert(title: "Warning", message: "No Such User")

                }else{
                    self.showAlert(title: "Added", message: "Added a Friend to this Group")
                }
            }
            
            
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true)
        
    }
    
    @objc func viewMembers(){
        let membersRef = privateChannelRef?.document(currentGroup!.id).collection("members")
        membersRef?.getDocuments(completion: { (querySnapshot, error) in
            if let error = error{
                print(error)
                return
            }
            self.groupMembers.removeAll()
            querySnapshot?.documents.forEach({ (document) in
                let id = document.documentID
                let name = document.get("name")
                let contact = Contact(id: id, name: name as! String)
                self.groupMembers.append(contact)

                
            })
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let popVC = storyboard.instantiateViewController(identifier: "PopVC") as! GroupMemberController
//            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
////            popVC.navigationItem.title = "Member List of \(self.currentGroup!.name)"
//            let item = UINavigationItem(title:"Member List of \(self.currentGroup!.name)")
//            navBar.setItems([item], animated: true)
//            popVC.view.addSubview(navBar)
            
            popVC.modalPresentationStyle = .popover
            //popVC.title = "Member List of \(self.currentGroup!.name)"
            popVC.groupMembers = self.groupMembers
            popVC.groupName = self.currentGroup?.name
            let popover = popVC.popoverPresentationController
            popover?.delegate = self
            popover?.barButtonItem = self.viewItem
            self.present(popVC, animated: true, completion: nil)

        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.messagesList.removeAll()
        databaseListener?.remove()
        
    }
    
    func currentSender() -> SenderType {
        guard let sender = sender else {
            return Sender(id: "",name: "")
        }
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messagesList.count
    }
    
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var name : String?
//        if currentChannel != nil{
//            name = message.sender.senderId
//        }
//        if currentContact != nil {
//            name = message.sender.displayName
//        }
        name = message.sender.displayName
        return NSAttributedString(string: name!, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        
    }
    
    // MARK: - Message Input Bar Delegate Functions
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text.isEmpty {
            return
        }
        if currentChannel != nil{
            channelRef?.addDocument(data: [ "senderId" : sender!.senderId, "senderName" : sender!.displayName, "text" : text, "time" : Timestamp(date: Date.init()) ])
            
        }
        if currentContact != nil {
            let receiverRef = database.collection("contacts").document(currentContact!.id).collection("friends").document(sender!.senderId).collection("messages")
            contactRef?.addDocument(data: [ "senderId" : sender!.senderId, "senderName" : sender!.displayName, "text" : text, "time" : Timestamp(date: Date.init()) ])
            receiverRef.addDocument(data: [ "senderId" : sender!.senderId, "senderName" : sender!.displayName, "text" : text, "time" : Timestamp(date: Date.init()) ])
        }
        
        if currentGroup != nil{
            let messageRef = privateChannelRef?.document(currentGroup!.id).collection("messages")
            messageRef?.addDocument(data: [ "senderId" : sender!.senderId, "senderName" : sender!.displayName, "text" : text, "time" : Timestamp(date: Date.init()) ])
        }
        
        
        inputBar.inputTextView.text = ""
    }
    
    // MARK: - MessagesLayoutDelegate
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
        
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
        
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
        
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

