//
//  ItemLocation.swift
//  TreasureHunter
//
//  Created by Stanford on 5/11/20.
//

import UIKit
//class ItemLocation:NSObject, Decodable{
//    var allItemLocation:[ItemLocation]?
//    private enum CodingKeys:String, Codingkey{
//        case allItemLocation = ""
//    }
//}
class ItemLocation: NSObject, Decodable {
    var id:String?
    var location:Location?
    var name:String?
    
    private enum CodingKeys: String, CodingKey{
        case id = "id"
        case location = "data.location"
        case name = "data.name"
    }
    
    required init(from decoder:Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(String.self,forKey: .id)
        location = try? container.decode(Location.self,forKey: .location)
        name = try? container.decode(String.self, forKey: .name)
    }
}

class Location :NSObject, Decodable {
    var latitude:Double?
    var longitude:Double?
    
    private enum CodingKeys: String, CodingKey{
        case latitude = "_latitude"
        case longitude = "_longitude"
    }
    
    required init(from decoder:Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try? container.decode(Double.self,forKey: .latitude)
        longitude = try? container.decode(Double.self,forKey: .longitude)
    }
    
}
