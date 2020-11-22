//
//  ShopCollectionViewCell.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 11/11/20.
//

import UIKit

// Class that handles each cell in the shop collection view
class ShopCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    var item: Item?
    
    // Configure the background of each cell
    func configureBackground(with imageName: String){
        backgroundImageView.image = UIImage(named: imageName)
    }
    
    // Configure the image of item of each cell
    func configureItemImage(with imageName: String){
        itemImage.image = UIImage(named: imageName)
    }
    
    // Configure the item of each cell
    func configureItem(with item: Item){
        self.item = item
        self.itemImage.image = item.imageIcon
    }

    // Configure the UI to display when a cell is selected
    func selectCell(){
        selectedImageView.image = UIImage(named: "selectFinger")
        
    }
    // Configures the UI to display when a cell is deselected
    func deselectCell(){
        selectedImageView.image = nil
    }
    
    // Configures the price label to display on the top right of the cell
    func configurePrice(with item: Item){
        let strokeTextAttributes = [
          NSAttributedString.Key.strokeColor : UIColor.black,
          NSAttributedString.Key.foregroundColor : UIColor.yellow,
          NSAttributedString.Key.strokeWidth : -4.0,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(rawValue: 20.0))]
          as [NSAttributedString.Key : Any]

        priceLabel.attributedText = NSMutableAttributedString(string: String(item.itemShopPrice!), attributes: strokeTextAttributes)
        
    }
    
}
