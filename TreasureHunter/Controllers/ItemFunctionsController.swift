//
//  File.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 10/11/20.
//

import Foundation

// Handles item use functions and buy from shop
class ItemFunctionsController{
    
    var homeViewDelegate: HomeViewDelegate?
    var bagViewDelegate: BagViewDelegate?
    var shopViewDelegate: ShopViewDelegate?
    
    init(){
    }
    
    func use(item: Item){
        switch item.name {
        case "Bottle Of Water":
            print("Using bottle of water")
            
            if homeViewDelegate!.getTimer() < 1 {
                homeViewDelegate?.showAlert(title: "Could not drink", message: "You can already dig!")
            } else {
                homeViewDelegate?.resetDigTimer()
                bagViewDelegate?.confirmItemUsed()
                bagViewDelegate?.showToast(message: "You feel refreshed and ready to dig again", font: .systemFont(ofSize: 16.0))
            }
        case "Normal Oyster":
            bagViewDelegate?.sellItem(forPrice: 500)
            bagViewDelegate?.showToast(message: "Normal Oyster sold for 500 gold", font: .systemFont(ofSize: 16.0))
            
        case "Large Treasure Chest":
            bagViewDelegate?.sellItem(forPrice: 5000)
            bagViewDelegate?.showToast(message: "Large Treasure Chest sold for 5000 gold" , font: .systemFont(ofSize: 16.0))
            
        case "Pearl Oyster":
            homeViewDelegate?.showAlert(title: "Congratulations!", message: "Admin will contact you via E-Mail")
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
        case "Energy Drink":
            if homeViewDelegate!.getDigRadius() > 10.0 {
                homeViewDelegate?.showAlert(title: "Could not drink", message: "Your next dig radius is already increased!")
            } else {
                homeViewDelegate?.increaseDigRadius(by: 20)
                bagViewDelegate?.confirmItemUsed()
                bagViewDelegate?.showToast(message: "Next dig radius increased by x3!", font: .systemFont(ofSize: 16.0))
            }
        default:
            print("Invalid Item")
        }
    }
       
}

