//
//  Item.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 26/10/20.
//

import Foundation
import UIKit


class Item: NSObject {
    
    var name: String?
    var desc: String?
    var imageIcon: UIImage?
    var dropChance: Int?
    var itemCount: Int?
    var itemShopPrice: Int?
    
    init(name: String, desc: String, imageIcon: UIImage, dropChance:Int){
        self.name = name
        self.desc = desc
        self.imageIcon = imageIcon
        self.dropChance = dropChance
    }
    init(name: String){
        self.name = name
    }
    init(name: String, itemCount: Int){
        self.name = name
        self.itemCount = itemCount
    }
    init(name: String, desc: String, imageIcon: UIImage){
        self.name = name
        self.desc = desc
        self.imageIcon = imageIcon
    }
    init(name: String, desc: String, imageIcon: UIImage, shopPrice: Int){
        self.name = name
        self.desc = desc
        self.imageIcon = imageIcon
        self.itemShopPrice = shopPrice
    }
    override init(){
    }
}


