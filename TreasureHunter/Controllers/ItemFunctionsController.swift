//
//  File.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 10/11/20.
//

import Foundation

class ItemFunctionsController{
    
    var homeViewDelegate: HomeViewDelegate?
    var bagViewDelegate: BagViewDelegate?
    
    init(){
        
    }

    func use(item: Item){
        switch item.name {
        case "Bottle Of Water":
            print("Using bottle of water")
            
            if homeViewDelegate!.getTimer() < 1 {
                homeViewDelegate?.showAlert(title: "Alert", message: "You cannot drink because you already can dig!")
            } else {
                homeViewDelegate?.resetDigTimer()
                bagViewDelegate?.confirmItemUsed()
                homeViewDelegate?.showAlert(title: "Drank Water", message: "You feel refreshed and ready to dig again")
            }
            
            
            
        case "Normal Oyster":
            homeViewDelegate?.showAlert(title: "Cannot Use This Item", message: "Normal Oyster can only be sold at the shop")
            print("Using normal Oyster")
            
        case "Pearl Oyster":
            break
            
        case "Map Piece 1":
            homeViewDelegate?.showAlertWithImage(title: "Hint 1", message: "P", imageName: "hint-kangaroo")
            
        case "Map Piece 2":
            homeViewDelegate?.showAlert(title: "Hint 2", message: "S")
            
        case "Map Piece 3":
            homeViewDelegate?.showAlertWithImage(title: "Hint 3", message: "O x2", imageName: "hint-tram")
            
        case "Map Piece 4":
            homeViewDelegate?.showAlert(title: "Hint 4", message: "TH")
            
        case "Map Piece 5":
            homeViewDelegate?.showAlertWithImage(title: "Hint 5", message: "M", imageName: "hint-uni")
            
        case "Map Piece 6":
            homeViewDelegate?.showAlert(title: "Hint 6", message: "N")
            
        default:
            print("Invalid Item")
        }
    }
    
    
}

