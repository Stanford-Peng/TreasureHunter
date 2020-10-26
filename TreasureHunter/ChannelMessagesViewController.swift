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

class ChannelMessagesViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var sender: Sender?
    var currentChannel: Channel?
    var messagesList = [ChannelMessage]()
    
    var channelRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
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
        
        if currentChannel != nil {
            let database = Firestore.firestore()
            channelRef = database.collection("channels").document(currentChannel!.id).collection("messages")
            navBar.topItem?.title = "\(currentChannel!.name)"
            //navigationItem.title = "\(currentChannel!.name)"
            
        }
        //view.addSubview(navBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        
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
        channelRef?.addDocument(data: [ "senderId" : sender!.senderId, "senderName" : sender!.displayName, "text" : text, "time" : Timestamp(date: Date.init()) ])
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

