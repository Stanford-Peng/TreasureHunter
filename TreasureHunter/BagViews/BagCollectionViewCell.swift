//
//  BagCollectionViewCell.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 26/10/20.
//

import UIKit

class BagCollectionViewCell: UICollectionViewCell {
    
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
}
