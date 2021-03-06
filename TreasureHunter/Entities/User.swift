//
//  User.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 20/11/20.
//

import Foundation
import UIKit

//Class storing properties of a user
class User: NSObject {
    
    var name: String?
    var digCount: Int?
    var earnedGold: Int?
    var score: Int?
    var pearlOyster: Int?
    
    init(name: String, digCount: Int, earnedGold: Int, pearlOyster: Int){
        self.name = name
        self.digCount = digCount
        self.earnedGold = earnedGold
        self.pearlOyster = pearlOyster
    }

    init(name: String, score: Int){
        self.name = name
        self.score = score
    }
    override init(){
    }
}


