//
//  ChannelMessage.swift
//
//  Created by Stanford on 19/10/20.
// // Reference: FIT5140 Lab 9 materials

import Foundation
import MessageKit
class ChannelMessage: MessageType, Equatable{
    
    static func == (lhs: ChannelMessage, rhs: ChannelMessage) -> Bool {
        return lhs.messageId == rhs.messageId && lhs.sentDate == rhs.sentDate

    }
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, message: String){
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(message)
        
    }
}


