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
            break
            
        case "Map Piece 2":
            break
            
        case "Map Piece 3":
            break
            
        case "Map Piece 4":
            break
            
        case "Map Piece 5":
            break
            
        case "Map Piece 6":
            break
            
        default:
            print("Invalid Item")
        }
    }
    
    
}

