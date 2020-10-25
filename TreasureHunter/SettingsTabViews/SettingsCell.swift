//
//  SettingsCell.swift
//  TreasureHunter
//
//  Created by Alston Hsing on 25/10/20.
//

import UIKit

class SettingsCell: UITableViewCell {

    // MARK: - Properties
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else {return}
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = .systemBlue
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = switchControl
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleSwitchAction(sender: UISwitch){
        if sender.isOn{
            print("is on")
        } else {
            print("is off")
        }
    }

}
