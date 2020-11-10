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
            bagViewDelegate!.showUseConfirmation()
            if homeViewDelegate!.getTimer() < 1 {
                homeViewDelegate?.showAlert(title: "Drank Water", message: "You could dig already, but you drank the bottle of water anyway")
            } else {
                homeViewDelegate?.showAlert(title: "Drank Water", message: "You feel refreshed and ready to dig again")
            }
            homeViewDelegate?.resetDigTimer()
        case "Normal Oyster":
            print("Using normal Oyster")
        default:
            print("Invalid Item")
        }
    }
    
    
}

