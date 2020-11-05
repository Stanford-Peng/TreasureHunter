//
//  BagCollectionViewCell.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 26/10/20.
//

import UIKit

class BagCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var cellBackground: UIImageView!
    func configure(with imageName: String){
        cellBackground.image = UIImage(named: imageName)
        
    }
}
