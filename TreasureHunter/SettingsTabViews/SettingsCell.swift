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
        switchControl.onTintColor = UIColor.Custom.darkBlue
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = switchControl
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleSwitchAction(sender: UISwitch){
        if sender.isOn{
            switch sectionType?.description{
            case "Hybrid Map":
                UserDefaults.standard.set("hybrid", forKey: "mapType")
            default:
                break
            }
            print("is on")
        } else {
            switch sectionType?.description{
            case "Hybrid Map":
                UserDefaults.standard.set("standard", forKey: "mapType")
            default:
                break
            }
            print("is off")
        }
    }
    
    func setupCell(){
        switch sectionType?.description {
        case "Hybrid Map":
            let mapType = UserDefaults.standard.string(forKey: "mapType")
            if mapType == "hybrid"{
                switchControl.isOn = true
            } else {
                switchControl.isOn = false
            }
        case "Notifications":
            break
        default:
            break
        }
    }

}
