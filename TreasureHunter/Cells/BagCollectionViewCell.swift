//
//  BagCollectionViewCell.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 26/10/20.
//

import UIKit

// Class handling each cell in user's bag
class BagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellSelectedImageView: UIImageView!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var cellBackground: UIImageView!
    @IBOutlet weak var cellItemImage: UIImageView!
    var item: Item?
    
    // Configures background of cell
    func configureBackground(with imageName: String){
        cellBackground.image = UIImage(named: imageName)
    }
    // Configures Item image of the cell item
    func configureItemImage(with imageName: String){
        cellItemImage.image = UIImage(named: imageName)
    }
    // Configures item of the cell
    func configureItem(with item: Item){
        self.item = item
        self.cellItemImage.image = item.imageIcon
    }
    
    // Configures count of items to display in the top right corner of the cell
    func configureItemCountLabel(){
        let strokeTextAttributes = [
          NSAttributedString.Key.strokeColor : UIColor.black,
          NSAttributedString.Key.foregroundColor : UIColor.white,
          NSAttributedString.Key.strokeWidth : -4.0,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(rawValue: 20.0))]
          as [NSAttributedString.Key : Any]

        itemCountLabel.attributedText = NSMutableAttributedString(string: String(item!.itemCount!), attributes: strokeTextAttributes)
    }
    
    // Configures the UI to display when a cell is selected
    func selectCell(){
        cellSelectedImageView.image = UIImage(named: "selectFinger")
        
    }
    
    // Configures the UI to display when a cell is deselected
    func deselectCell(){
        cellSelectedImageView.image = nil
    }
}
