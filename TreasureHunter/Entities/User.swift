//
//  User.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 20/11/20.
//

import Foundation
import UIKit

class User: NSObject {
    
    var name: String?
    var digCount: Int?
    var gold: Int?
    var score: Int?
    
    init(name: String, digCount: Int, gold: Int){
        self.name = name
        self.digCount = digCount
        self.gold = gold
    }

    init(name: String, score: Int){
        self.name = name
        self.score = score
    }
    override init(){
    }
}


