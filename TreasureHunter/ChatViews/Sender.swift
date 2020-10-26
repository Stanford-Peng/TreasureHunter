//
//  Sender.swift
// Reference: FIT5140 Lab 9 materials
//
//  Created by Stanford on 19/10/20.
//

import Foundation
import MessageKit
class Sender: SenderType{

    
    var senderId:String
    var displayName: String
    
    init(id:String, name: String) {
        senderId = id
        displayName = name
    }
}


