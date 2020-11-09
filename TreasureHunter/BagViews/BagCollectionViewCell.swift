//
//  BagCollectionViewCell.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 26/10/20.
//

import UIKit

class BagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellBackground: UIImageView!
    @IBOutlet weak var cellItemImage: UIImageView!
    
    func configureBackground(with imageName: String){
        cellBackground.image = UIImage(named: imageName)
    }
    func configureItemImage(with imageName: String){
        cellItemImage.image = UIImage(named: imageName)
    }
}
