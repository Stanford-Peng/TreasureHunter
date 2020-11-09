//
//  BagCollectionViewCell.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 26/10/20.
//

import UIKit

class BagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellSelectedImageView: UIImageView!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var cellBackground: UIImageView!
    @IBOutlet weak var cellItemImage: UIImageView!
    var item: Item?
    
    func configureBackground(with imageName: String){
        cellBackground.image = UIImage(named: imageName)
    }
    func configureItemImage(with imageName: String){
        cellItemImage.image = UIImage(named: imageName)
    }
    func configureItem(with item: Item){
        self.item = item
        self.cellItemImage.image = item.imageIcon
    }
    func configureItemCountLabel(){
        let strokeTextAttributes = [
          NSAttributedString.Key.strokeColor : UIColor.black,
          NSAttributedString.Key.foregroundColor : UIColor.white,
          NSAttributedString.Key.strokeWidth : -4.0,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(rawValue: 20.0))]
          as [NSAttributedString.Key : Any]

        itemCountLabel.attributedText = NSMutableAttributedString(string: String(item!.itemCount!), attributes: strokeTextAttributes)
    }
    func selectCell(){
        cellSelectedImageView.image = UIImage(named: "selectFinger")
        
    }
    func deselectCell(){
        cellSelectedImageView.image = nil
    }
}
